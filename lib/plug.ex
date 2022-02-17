defmodule Existence.Plug do
  @moduledoc """
  Plug sending information about a health-check state as a response.


  Plug sends a plain text response dependent on the overall health-check state.

  Response http status code and body are configurable with the following keys:
  * `ok_status` - response status code for the healthy state. Default: `200`.
  * `ok_body` - response body for the healthy state. Default: `"OK"`.
  * `error_status` - response status code for the unhealthy state. Default: `503`.
  * `error_body` - response body for the unhealthy state. Default: `"Service Unavailable"`.


  Example module use with `Plug.Router.get/3` inside `/` route scope with custom unhealthy
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
  Notice `alias: false` use to disable scoping on an external `Existence.Plug`.

  Above code example will produce following http responses:
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
  import Plug.Conn
  alias Existence.GenCheck

  @ok_status 200
  @ok_body "OK"
  @error_status 503
  @error_body "Service Unavailable"

  @doc false
  def init(opts \\ []), do: opts

  @doc false
  def call(conn, opts \\ []) do
    {status, body} =
      case GenCheck.get_state() do
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
