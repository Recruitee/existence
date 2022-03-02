defmodule Existence do
  @moduledoc """
  Health-checks start and state access module.

  Module provides functions for accessing an overall health-check state and individual dependencies
  checks results.
  Module is also used to start an `Existence` process as a part of an application supervision tree.

  `Existence` works by asynchronously spawning user defined dependencies checks functions.
  Individual dependencies checks functions results are evaluated to establish an overall
  health-check state.
  Overall health-check state is healthy only when all user defined dependencies checks are healthy.
  It is assumed that healthy state is represented by an `:ok` atom for both dependencies checks and
  for the overall health-check.
  Any other result in dependencies checks is associated with an unhealthy dependency check state.
  Overall health-check unhealthy state is represented by an `:error` atom.

  User defined dependencies checks functions are spawned as monitored isolated processes.
  If user dependency check function raises, throws an error, timeouts or fails in any way it
  doesn't have a negative impact on other processes, including user application.

  Current dependencies checks functions results and current overall health-check state are stored
  in an ETS table.
  Whenever user executes any of available state getters, `get_state/1` or `get_checks/1`,
  request is made against ETS table which has `:read_concurrency` set to `true`.
  In practice it means that library can handle huge numbers of requests per second
  without blocking any other processes.

  Module provides two functions to access checks states:
  * `get_state/1` to get overall health-check state,
  * `get_checks/1` to get dependencies checks states.

  ## Usage
  After defining dependencies checks parameters, `Existence` can be started using
  your application supervisor:
  ```elixir
  #lib/my_app/application.ex
  def start(_type, _args) do
    health_checks = [
      # minimal dependency check configuration:
      check_1: %{
        mfa: {MyApp.Checks, :check_1, []}
      },
      # complete dependency check configuration:
      check_2: %{
        mfa: {MyApp.Checks, :check_2, []},
        initial_delay: 1_000,
        interval: 30_000,
        state: :ok,
        timeout: 1_000
      }
    ]

    children = [
      {Existence, checks: health_checks, state: :ok}
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
  ```
  When `Existence` is started it has assigned an initial overall health-check state, which
  by default is equal to an `:error` atom, meaning an unhealthy state.
  Initial overall health-check state can be changed with a `:state` key. In a code example above
  initial overall health-check state is set to a healthy state with: `state: :ok`.

  `Existence` supports starting multiple instances by using common Elixir child identifiers:
  `:id` and `:name`, for example:
  ```elixir
  children = [
    {Existence, id: ExistenceReadiness, name: ReadinessCheck},
    {Existence, name: {:local, LivenessCheck}}
  ]
  ```

  ## Configuration
  `Existence` startup options:
  * `:id` - any term used to identify the child specification internally. Please refer to the
  `Supervisor` "Child specification" documentation section for details on child `:id` key.
  Default: `Existence`.
  * `:name` - name used to start `Existence` `:gen_statem` process locally. If defined
  as an `atom()` `:gen_statem.start_link/3` is used to start `Existence` process
  without registration.
  If defined as a `{:local, atom()}` tuple, `:gen_statem.start_link/4` is invoked and process is
  registered locally with a given name.
  Key value is used to select `Existence` instance when running `get_state/1` or `get_checks/1`.
  Default: `Existence`.
  * `:checks` - keyword list with user defined dependencies checks parameters, see description
  below for details. Default: `[]`.
  * `:state` - initial overall `Existence` instance health-check state. Default: `:error`.

  Dependencies checks are defined using a keyword list with configuration parameters defined
  as a maps.

  Dependencies checks configuration options:
  * `:mfa` - `{module, function, arguments}` tuple specifying user defined function to spawn when
  executing given dependency check. Please refer to `Kernel.apply/3` documentation for
  the MFA pattern explanation. Required.
  * `:initial_delay` - amount of time in milliseconds to wait before spawning a dependency check
  for the first time. Can be used to wait for a dependency process to properly initialize before
  executing dependency check function first time when application is started. Default: `100`.
  * `:interval` - time interval in milliseconds specifying how frequently given check should be
  executed. Default: `30_000`.
  * `:state` - initial dependency check state when starting `Existence`. Default: `:error`.
  * `:timeout` - after spawning dependency check function library will wait `:timeout` amount of
  milliseconds for the dependency check function to complete.
  If dependency check function will do not complete within a given timeout, dependency check
  function process will be killed, and dependency check state will assume a `:killed` atom value.
  Default: `5_000`.

  ## Dependencies checks
  User defined dependencies checks functions must return an `:ok` atom for the healthy state.
  Any other values returned by dependencies checks functions are considered as an unhealthy state.

  Example checks for two popular dependencies, PostgreSQL and Redis:
  ```elixir
  #lib/checks.ex
  def check_postgres() do
    "SELECT 1;"
    |> MyApp.Repo.query()
    |> case do
      {:ok, %Postgrex.Result{num_rows: 1, rows: [[1]]}} -> :ok
      _ -> :error
    end
  end

  def check_redis() do
    case MyApp.Redix.command(["PING"]) do
      {:ok, "PONG"} -> :ok
      _ -> :error
    end
  end
  ```
  Please notice that dependencies checks functions in the code example above are not wrapped in a
  `try/1` blocks.
  Dependencies checks functions are spawned as monitored processes.
  Whenever check function will raise, parent health-check process will be notified with an `:info`
  `:DOWN` message and dependency check status will be assigned a tuple containing an exception and
  a stack trace, for example:
  ```elixir
  # def check_1(), do: raise("CustomError")
  iex> Existence.get_checks()
  [
    check_1: {%RuntimeError{message: "CustomError"}, [ # ... stack trace ]}
  ]
  iex> Existence.get_state()
  :error
  ```
  """

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

  # TODO decide if ets_exists?/1 should be executed on each get_* call
  # def ets_exists?(table \\ @ets_table_name), do: :ets.whereis(table) != :undefined

  @doc """
  Get dependencies checks states.

  Function gets current dependencies checks states for an `Existence` instance started with
  a given `name`.
  If `name` is not provided, checks states for instance with default `:name` (`Existence`)
  are returned.

  Dependencies checks functions results are returned as a keyword list.
  If no checks were defined function will return an empty list.

  Dependency check function result equal to an `:ok` atom means healthy state, any other term is
  associated with an unhealthy state.

  Function will raise with an `ArgumentError` exception if `Existence` instance `name`
  doesn't exist.

  ##### Example:
  ```elixir
  iex> Existence.get_checks()
  [check_1: :ok, check_2: :ok]
  ```

  ```
  iex> Existence.get_checks(NotExisting)
  ** (ArgumentError) errors were found at the given arguments:
  ```

  """
  @spec get_checks(name :: atom()) :: [] | [key: :ok | any()]
  def get_checks(name \\ __MODULE__) do
    name
    |> ets_table_name()
    |> :ets.select([{{{:check_state, :"$1"}, :"$2"}, [], [{{:"$1", :"$2"}}]}])
  end

  @doc """
  Get an overall health-check state.

  Function gets current overall health-check state for an `Existence` instance started with
  a given `name`.
  If `name` is not provided, overall health-check state for an instance with default `:name`
  (`Existence`) is returned.

  Function returns an `:ok` atom when overall health-check state is healthy and an `:error` atom
  otherwise.
  Overall health-check state is healthy only when all dependencies health checks are healthy.

  Function will raise with an `ArgumentError` exception if `Existence` instance `name`
  doesn't exist.

  ##### Example:
  ```elixir
  iex> Existence.get_state()
  :ok
  ```

  ```elixir
  iex> Existence.get_state(NotExisting)
  ** (ArgumentError) errors were found at the given arguments:
  ```
  """
  @spec get_state(name :: atom()) :: :ok | :error
  def get_state(name \\ __MODULE__) do
    [{:state, state}] =
      name
      |> ets_table_name()
      |> :ets.lookup(:state)

    state
  end

  @doc false
  def child_spec(init_arg) do
    {id, init_arg} = Keyword.pop(init_arg, :id, __MODULE__)
    Supervisor.child_spec(%{id: id, start: {__MODULE__, :start_link, [init_arg]}}, [])
  end

  @doc false
  def start_link(init_arg) do
    case Keyword.pop(init_arg, :name, __MODULE__) do
      {name, init_arg} when is_atom(name) ->
        init_arg = Keyword.put(init_arg, :ets_name, ets_table_name(name))
        :gen_statem.start_link(__MODULE__, init_arg, [])

      {{:local, name}, init_arg} when is_atom(name) ->
        init_arg = Keyword.put(init_arg, :ets_name, ets_table_name(name))
        :gen_statem.start_link({:local, name}, __MODULE__, init_arg, [])
    end
  end

  @impl true
  def init(args) do
    Process.flag(:trap_exit, true)
    ets_tab = Keyword.fetch!(args, :ets_name)

    :ets.new(ets_tab, [
      :set,
      :named_table,
      :public,
      read_concurrency: true,
      write_concurrency: false
    ])

    checks =
      args
      |> Keyword.get(:checks, [])
      |> Enum.map(fn {check_id, params} -> {check_id, struct!(__MODULE__, params)} end)

    Enum.each(checks, fn {check_id, params} ->
      set_check_state(%{ets_tab: ets_tab}, check_id, Map.fetch!(params, :state))
      Process.send_after(self(), {:spawn_check, check_id}, Map.fetch!(params, :initial_delay))
    end)

    data = %{checks: checks, ets_tab: ets_tab}

    case Keyword.get(args, :state, :error) do
      :ok -> {:ok, :healthy, data}
      _ -> {:ok, :unhealthy, data}
    end
  end

  @impl true
  def callback_mode(), do: [:state_functions, :state_enter]

  @impl true
  def terminate(_reason, _state, data), do: set_state(data, :terminate)

  # ________unhealthy
  @doc false
  def unhealthy(:enter, state, data) when state in [:healthy, :unhealthy] do
    set_state(data, :unhealthy)
    :keep_state_and_data
  end

  def unhealthy(:info, {:check_result, result, check_id}, data) do
    set_check_state(data, check_id, result)

    if is_ets_healthy?(data),
      do: {:next_state, :healthy, data},
      else: {:keep_state, data}
  end

  def unhealthy(:info, {:DOWN, ref, :process, pid, :normal}, data) do
    find_check(pid, ref, data)
    |> maybe_respawn_check()

    :keep_state_and_data
  end

  def unhealthy(:info, {:DOWN, ref, :process, pid, error}, data) do
    {check_id, _check_params} = check = find_check(pid, ref, data)
    maybe_respawn_check(check)
    set_check_state(data, check_id, error)

    :keep_state_and_data
  end

  def unhealthy(:info, {:spawn_check, check_id}, data),
    do: {:keep_state, spawn_check(check_id, data)}

  # ________healthy
  @doc false
  def healthy(:enter, state, data) when state in [:healthy, :unhealthy] do
    set_state(data, :healthy)
    :keep_state_and_data
  end

  def healthy(:info, {:check_result, result, check_id}, data) do
    set_check_state(data, check_id, result)

    case result do
      :ok -> {:keep_state, data}
      _err -> {:next_state, :unhealthy, data}
    end
  end

  def healthy(:info, {:DOWN, ref, :process, pid, :normal}, data) do
    find_check(pid, ref, data)
    |> maybe_respawn_check()

    :keep_state_and_data
  end

  def healthy(:info, {:DOWN, ref, :process, pid, error}, data) do
    {check_id, _check_params} = check = find_check(pid, ref, data)
    maybe_respawn_check(check)
    set_check_state(data, check_id, error)

    {:next_state, :unhealthy, data}
  end

  def healthy(:info, {:spawn_check, check_id}, data),
    do: {:keep_state, spawn_check(check_id, data)}

  # ________helpers
  defp ets_table_name(name), do: Module.concat(name, Table)

  defp find_check(pid, ref, %{checks: checks}),
    do: Enum.find(checks, nil, fn {_check_id, params} -> {pid, ref} == params.spawn_proc end)

  defp maybe_respawn_check({check_id, check_params}),
    do: Process.send_after(self(), {:spawn_check, check_id}, check_params.interval)

  defp maybe_respawn_check(_invalid_check), do: :ok

  defp spawn_check(check_id, %{checks: checks} = data) do
    %{mfa: {m, f, a}, timeout: timeout} = params = Keyword.fetch!(checks, check_id)
    from = self()

    {pid, ref} =
      spawn_monitor(fn ->
        :timer.kill_after(timeout, self())
        result = apply(m, f, a)
        send(from, {:check_result, result, check_id})
      end)

    params = Map.put(params, :spawn_proc, {pid, ref})
    checks = Keyword.put(checks, check_id, params)
    Map.put(data, :checks, checks)
  end

  defp set_state(%{ets_tab: ets_tab}, state) do
    case state do
      :healthy -> :ets.insert(ets_tab, {:state, :ok})
      _ -> :ets.insert(ets_tab, {:state, :error})
    end
  end

  defp set_check_state(%{ets_tab: ets_tab}, check_id, result),
    do: :ets.insert(ets_tab, {{:check_state, check_id}, result})

  defp is_ets_healthy?(%{ets_tab: ets_tab}) do
    case :ets.select(ets_tab, [
           {{{:check_state, :"$1"}, :"$2"}, [{:"/=", :"$2", :ok}], [:"$2"]}
         ]) do
      [] -> true
      _ -> false
    end
  end
end
