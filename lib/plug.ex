defmodule Existence.Plug do
  @moduledoc """
  Plug sending a health check status response.
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
