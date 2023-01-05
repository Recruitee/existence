defmodule Existence.Plug do
  @moduledoc """
  Plug responding with a health-check state.

  Plug sends a `text/plain` response depending on the `Existence` overall health-check state
  returned by an `Existence.get_state/1` or `Existence.get_state!/1` function.

  ## Configuration
  Plug is configured with a keyword list.

  Plug response http status code and body are configurable with the following keys:
  * `:ok_status` - response status code for the healthy state. Default: `200`.
  * `:ok_body` - response body for the healthy state. Default: `"OK"`.
  * `:error_status` - response status code for the unhealthy state. Default: `503`.
  * `:error_body` - response body for the unhealthy state. Default: `"Service Unavailable"`.

  Other configuration options:
  * `:raising?` - if set to `true` plug will use `Existence.get_state!/1` raising function to
    get an overall health-check state.
    If set to false, not raising `Existence.get_state/1` function will be used.
    Default: `false`.
  * `:name` - instance name defined when starting `Existence` child with supervision tree.
    Default: `Existence`.

  ## Usage
  Example module use with a `Plug.Router.get/3` inside `/` route scope with a custom unhealthy
  state response:
  ```elixir
  defmodule MyAppWeb.Router do
  use MyAppWeb, :router

    #...
    scope "/", MyAppWeb do
      pipe_through(:browser)

      get(
        "/healthcheck",
        Existence.Plug,
        [error_status: 500, error_body: "Internal Server Error"],
        alias: false
      )
    end
  end

  ```
  Notice `alias: false` use to disable scoping on an external `Existence.Plug` in `get/3` function.

  Code example above will produce following http responses:
  * healthy state:
  ```
  $> curl -i http://127.0.0.1:4000/healthcheck
  HTTP/1.1 200 OK
  ...
  OK
  ```
  * unhealthy state:
  ```
  $> curl -i http://127.0.0.1:4000/healthcheck
  HTTP/1.1 500 Internal Server Error
  ...
  Internal Server Error
  ```
  """

  @behaviour Plug

  import Plug.Conn, only: [put_resp_content_type: 2, send_resp: 3, halt: 1]

  @ok_status 200
  @ok_body "OK"
  @error_status 503
  @error_body "Service Unavailable"

  @default_raising? false
  @default_name Existence

  @doc false
  def init(opts \\ []), do: opts

  @doc false
  def call(conn, opts \\ []) do
    name = Keyword.get(opts, :name, @default_name)

    health_check_state =
      if Keyword.get(opts, :raising?, @default_raising?),
        do: Existence.get_state!(name),
        else: Existence.get_state(name)

    {status, body} =
      case health_check_state do
        :ok ->
          {Keyword.get(opts, :ok_status, @ok_status), Keyword.get(opts, :ok_body, @ok_body)}

        _ ->
          {Keyword.get(opts, :error_status, @error_status),
           Keyword.get(opts, :error_body, @error_body)}
      end

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(status, body)
    |> halt()
  end
end
