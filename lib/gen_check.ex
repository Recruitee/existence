defmodule Existence.GenCheck do
  @moduledoc false
  @behaviour :gen_statem

  @ets_table_name Module.concat(__MODULE__, Table)

  @enforce_keys [:fun]

  defstruct [
    :fun,
    interval: 30_000,
    initial_delay: 100,
    state: :error,
    timeout: 15_000,
    spawn_proc: {nil, nil}
  ]

  # TODO move fun to mfa

  # {:state, :ok}
  # {:state, type()}
  # {{:check_state, id}, :ok}
  # {{:check_state, id}, type()}

  # Plug :ok / :error -> {}
  # @ok_status 200
  # @ok_body "OK"
  # @error_status 503
  # @error_body "Service Unavailable"

  def get_state() do
  end

  def get_check_state(_id) do
  end

  def start_link(init_arg) do
    # :gen_statem.start_link(__MODULE__, init_arg, debug: [:trace])
    :gen_statem.start_link(__MODULE__, init_arg, [])
  end

  def child_spec(init_arg),
    do: Supervisor.child_spec(%{id: __MODULE__, start: {__MODULE__, :start_link, [init_arg]}}, [])

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
      |> Enum.map(fn {id, params} -> {id, struct!(__MODULE__, params)} end)

    Enum.each(data, fn {id, params} ->
      Process.send_after(
        self(),
        {:spawn_check, id},
        Map.fetch!(params, :initial_delay)
      )
    end)

    case Keyword.get(args, :state, :error) do
      :ok -> {:ok, :healthy, data}
      _ -> {:ok, :unhealthy, data}
    end
  end

  @impl true
  def callback_mode(), do: [:state_functions, :state_enter]

  @impl true
  def terminate(_reason, _state, _data), do: set_state(:unhealthy)

  # ________unhealthy
  def unhealthy(:enter, :unhealthy, _data) do
    set_state(:unhealthy)
    :keep_state_and_data
  end

  def unhealthy(:enter, :healthy, _data) do
    set_state(:unhealthy)
    :keep_state_and_data
  end

  def unhealthy(:info, {:check_result, result, id}, data) do
    set_check_state(id, result)
    data = update_check_result(result, id, data)

    case Enum.find(data, :ok, fn {_id, params} -> Map.fetch!(params, :state) != :ok end) do
      :ok -> {:next_state, :healthy, data}
      _err -> {:keep_state, data}
    end
  end

  def unhealthy(:info, {:DOWN, ref, :process, pid, _status}, data) do
    maybe_respawn_check(ref, pid, data)
    :keep_state_and_data
  end

  def unhealthy(:info, {:spawn_check, id}, data), do: {:keep_state, spawn_check(id, data)}

  # ________healthy
  def healthy(:enter, :healthy, _data) do
    set_state(:healthy)
    :keep_state_and_data
  end

  def healthy(:enter, :unhealthy, _data) do
    set_state(:healthy)
    :keep_state_and_data
  end

  def healthy(:info, {:check_result, result, id}, data) do
    set_check_state(id, result)
    data = update_check_result(result, id, data)

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

  def healthy(:info, {:spawn_check, id}, data), do: {:keep_state, spawn_check(id, data)}

  # ________helpers
  defp update_check_result(result, id, data) do
    new_params =
      data
      |> Keyword.fetch!(id)
      |> Map.put(:state, result)

    Keyword.put(data, id, new_params)
  end

  defp maybe_respawn_check(ref, pid, data) do
    check = Enum.find(data, nil, fn {_id, params} -> {pid, ref} == params.spawn end)

    case check do
      {id, params} -> Process.send_after(self(), {:spawn_check, id}, params.interval)
      _ -> :ok
    end
  end

  defp spawn_check(id, data) do
    %{fun: {m, f}, timeout: timeout} = params = Keyword.fetch!(data, id)
    from = self()

    {pid, ref} =
      spawn_monitor(fn ->
        :timer.kill_after(timeout, self())
        result = apply(m, f, [])
        send(from, {:check_result, result, id})
      end)

    params = Map.put(params, :spawn, {pid, ref})
    Keyword.put(data, id, params)
  end

  defp set_state(state) do
    state |> IO.inspect()
  end

  defp set_check_state(id, result) do
    IO.puts("#{id} -> #{inspect(result)}")
  end
end
