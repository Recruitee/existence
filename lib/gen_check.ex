defmodule Existence.GenCheck do
  @moduledoc false
  @behaviour :gen_statem

  @enforce_keys [:mfa]
  defstruct [
    :mfa,
    initial_delay: 100,
    interval: 30_000,
    state: :error,
    timeout: 5_000,
    spawn_proc: {nil, nil}
  ]

  @ets_table_name Module.concat(__MODULE__, Table)

  def get_state() do
    [{:state, state}] = :ets.lookup(@ets_table_name, :state)
    state
  end

  def get_check_state(check_id) do
    [{{:check_state, ^check_id}, state}] = :ets.lookup(@ets_table_name, {:check_state, check_id})
    state
  end

  def child_spec(init_arg),
    do: Supervisor.child_spec(%{id: __MODULE__, start: {__MODULE__, :start_link, [init_arg]}}, [])

  def start_link(init_arg), do: :gen_statem.start_link(__MODULE__, init_arg, [])

  @impl true
  def init(args) do
    Process.flag(:trap_exit, true)

    :ets.new(@ets_table_name, [
      :set,
      :named_table,
      :public,
      read_concurrency: true,
      write_concurrency: false
    ])

    data =
      Mix.Project.config()
      |> Keyword.fetch!(:app)
      |> Application.get_env(Existence, [])
      |> Enum.map(fn {check_id, params} -> {check_id, struct!(__MODULE__, params)} end)

    Enum.each(data, fn {check_id, params} ->
      Process.send_after(self(), {:spawn_check, check_id}, Map.fetch!(params, :initial_delay))
    end)

    case Keyword.get(args, :state, :error) do
      :ok -> {:ok, :healthy, data}
      _ -> {:ok, :unhealthy, data}
    end
  end

  @impl true
  def callback_mode(), do: [:state_functions, :state_enter]

  @impl true
  def terminate(_reason, _state, _data), do: set_state(:terminate)

  # ________unhealthy
  def unhealthy(:enter, state, _data) when state in [:healthy, :unhealthy] do
    set_state(:unhealthy)
    :keep_state_and_data
  end

  def unhealthy(:info, {:check_result, result, check_id}, data) do
    set_check_state(check_id, result)
    data = update_check_result(result, check_id, data)

    case Enum.find(data, :ok, fn {_check_id, params} -> Map.fetch!(params, :state) != :ok end) do
      :ok -> {:next_state, :healthy, data}
      _err -> {:keep_state, data}
    end
  end

  def unhealthy(:info, {:DOWN, ref, :process, pid, _status}, data) do
    maybe_respawn_check(ref, pid, data)
    :keep_state_and_data
  end

  def unhealthy(:info, {:spawn_check, check_id}, data),
    do: {:keep_state, spawn_check(check_id, data)}

  # ________healthy
  def healthy(:enter, state, _data) when state in [:healthy, :unhealthy] do
    set_state(:healthy)
    :keep_state_and_data
  end

  def healthy(:info, {:check_result, result, check_id}, data) do
    set_check_state(check_id, result)
    data = update_check_result(result, check_id, data)

    case result do
      :ok -> {:keep_state, data}
      _err -> {:next_state, :unhealthy, data}
    end
  end

  def healthy(:info, {:DOWN, ref, :process, pid, :normal}, data) do
    maybe_respawn_check(ref, pid, data)
    :keep_state_and_data
  end

  def healthy(:info, {:DOWN, ref, :process, pid, _error}, data) do
    maybe_respawn_check(ref, pid, data)
    {:next_state, :unhealthy, data}
  end

  def healthy(:info, {:spawn_check, check_id}, data),
    do: {:keep_state, spawn_check(check_id, data)}

  # ________helpers
  defp update_check_result(result, check_id, data) do
    new_params =
      data
      |> Keyword.fetch!(check_id)
      |> Map.put(:state, result)

    Keyword.put(data, check_id, new_params)
  end

  defp maybe_respawn_check(ref, pid, data) do
    check = Enum.find(data, nil, fn {_check_id, params} -> {pid, ref} == params.spawn_proc end)

    case check do
      {check_id, params} -> Process.send_after(self(), {:spawn_check, check_id}, params.interval)
      _ -> :ok
    end
  end

  defp spawn_check(check_id, data) do
    %{mfa: {m, f, a}, timeout: timeout} = params = Keyword.fetch!(data, check_id)
    from = self()

    {pid, ref} =
      spawn_monitor(fn ->
        :timer.kill_after(timeout, self())
        result = apply(m, f, a)
        send(from, {:check_result, result, check_id})
      end)

    params = Map.put(params, :spawn_proc, {pid, ref})
    Keyword.put(data, check_id, params)
  end

  defp set_state(state) do
    case state do
      :healthy -> :ets.insert(@ets_table_name, {:state, :ok})
      _ -> :ets.insert(@ets_table_name, {:state, :error})
    end
  end

  defp set_check_state(check_id, result),
    do: :ets.insert(@ets_table_name, {{:check_state, check_id}, result})
end
