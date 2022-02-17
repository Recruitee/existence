defmodule Existence do
  @moduledoc """
  Health-checks start and state access module.

  Module provides functions for accessing an overall health-check state and individual dependencies
  checks results.
  Module is also used to start an `Existence` process as a part of an application supervision tree.

  `Existence` works by asynchronously spawning user defined dependencies checks functions.
  Dependencies checks functions results are evaluated to establish overall health-check state.
  Overall health-check state is healthy only when all user defined dependencies checks are healthy.
  It is assumed that healthy state is represented by an `:ok` atom for both dependencies checks and
  for an overall health-check.
  Any other result in dependencies checks is associated with an unhealthy state. Unhealthy overall
  health-check state is represented by the `:error` atom.

  User provided dependencies checks functions are spawned as an isolated processes.
  If dependency check function raises, throws an error, timeouts or fails in any other way it
  doesn't have a negative impact on other processes, including user application.
  Current checks results are stored in an ETS table. When user executes any of available getters,
  `get_state/0` or `get_checks/0`, request is made against ETS table which has `:read_concurrency`
  set to `true`. In practice it means that library can handle huge numbers of requests per second
  without blocking process managing health-checks execution and evaluation.

  You can start `Existence` using `start/2` in your application supervisor:
  ```elixir
  #lib/my_app/application.ex
  def start(_type, _args) do
    children = [
      {Existence, state: :ok}
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
  ```
  When `Existence` is started it has assigned by default initial state `:error`,
  which means an unhealthy state. User can change initial health-check state using `:state` key.
  Initial overall health-check is set to healthy in a code example above by setting: `state: :ok`.

  User defined dependencies checks are configured in the Elixir config, usually
  `config/config.exs` file:
  ```elixir
  #config/config.exs
  config :my_app, Existence,
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

  ```
  Dependencies checks are identified by their atom id's with configuration settings defined
  as a map.

  Dependencies checks configuration options:
  * `:mfa` - `{module, function, arguments}` tuple specifying user defined function to run when
  spawning given check. Please refer to `Kernel.apply/3` for `mfa` pattern explanation. Required.
  * `:initial_delay` - amount of time in milliseconds to wait before spawning a dependency check
  for the first time. Can be used to wait for a dependency process to properly initialize before
  executing check function first time when application is started. Default: `100 msec`.
  * `:interval` - time interval in milliseconds specifying how frequently given check should be
  executed. Default: `30_000 msec`.
  * `:state` - initial dependency check state when starting `Existence`. Default: `:error`.
  * `:timeout` - after spawning dependency check function library will wait `:timeout` amount of
  milliseconds for the check function result. If check function will do not complete within a given
  timeout, check function process will be killed, and check state will be assigned `:killed` atom
  value. Default: `5_000 msec`.

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
  Please notice that checks commands in the code examples above are not wrapped in a
  `try/1` blocks like in other similar libraries.
  Checks functions are spawned as monitored processes. Whenever they will raise, parent
  health-check process will be notified and will align checks statuses accordingly.
  Using `try/1` is unnecessary.


  Module provides two functions to access checks states:
  * `get_state/0` to get overall health-check,
  * `get_checks/0` to get dependencies checks states.
  """

  alias Existence.GenCheck

  @doc """
  Get dependencies checks states.

  Returns a keyword list with checks functions results for the user configured dependencies checks.

  Returns an empty list if no checks were defined.

  Example:
  ```elixir
  iex> Existence.get_checks()
  [check_1: :ok, check_2: :ok]
  ```
  """
  @spec get_checks() :: [] | [key: :ok | any()]
  defdelegate get_checks(), to: GenCheck

  @doc """
  Get an overall health-check state.

  Returns `:ok` when overall health-check state is healthy, `:error` otherwise.

  Example:
  ```elixir
  iex> Existence.get_state()
  :ok
  ```
  """
  @spec get_state() :: :ok | :error
  defdelegate get_state(), to: GenCheck

  @doc false
  defdelegate child_spec(init_arg), to: GenCheck
end
