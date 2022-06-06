defmodule Existence.PlugTest do
  defmodule HealthRouter do
    use Plug.Router

    @custom_response [
      ok_status: 222,
      ok_body: "OK_custom",
      error_status: 555,
      error_body: "Error_custom"
    ]

    plug :match
    plug :dispatch

    get "/healthcheck_get_default", to: Existence.Plug
    get "/healthcheck_get_custom", to: Existence.Plug, init_opts: @custom_response

    forward "/healthcheck_fw_default", to: Existence.Plug
    forward "/healthcheck_fw_custom", to: Existence.Plug, init_opts: @custom_response
  end

  use ExUnit.Case, async: true
  use Plug.Test

  @default_response [
    ok_status: 200,
    ok_body: "OK",
    error_status: 503,
    error_body: "Service Unavailable"
  ]
  @custom_response [
    ok_status: 222,
    ok_body: "OK_custom",
    error_status: 555,
    error_body: "Error_custom"
  ]

  describe "standard router with initial FSM state: :error" do
    setup do
      start_supervised!(Existence)
      :ok
    end

    test "get with default response" do
      conn = conn(:get, "/healthcheck_get_default") |> HealthRouter.call([])
      assert conn.state == :sent
      assert conn.status == @default_response[:error_status]
      assert conn.resp_body == @default_response[:error_body]
    end

    test "get with custom response" do
      conn = conn(:get, "/healthcheck_get_custom") |> HealthRouter.call([])
      assert conn.state == :sent
      assert conn.status == @custom_response[:error_status]
      assert conn.resp_body == @custom_response[:error_body]
    end

    test "forward with default response" do
      conn = conn(:get, "/healthcheck_fw_default") |> HealthRouter.call([])
      assert conn.state == :sent
      assert conn.status == @default_response[:error_status]
      assert conn.resp_body == @default_response[:error_body]
    end

    test "forward with custom response" do
      conn = conn(:get, "/healthcheck_fw_custom") |> HealthRouter.call([])
      assert conn.state == :sent
      assert conn.status == @custom_response[:error_status]
      assert conn.resp_body == @custom_response[:error_body]
    end
  end

  describe "standard router with initial FSM state: :ok" do
    setup do
      start_supervised!({Existence, state: :ok})
      :ok
    end

    test "get with default response" do
      conn = conn(:get, "/healthcheck_get_default") |> HealthRouter.call([])
      assert conn.state == :sent
      assert conn.status == @default_response[:ok_status]
      assert conn.resp_body == @default_response[:ok_body]
    end

    test "get with custom response" do
      conn = conn(:get, "/healthcheck_get_custom") |> HealthRouter.call([])
      assert conn.state == :sent
      assert conn.status == @custom_response[:ok_status]
      assert conn.resp_body == @custom_response[:ok_body]
    end

    test "forward with default response" do
      conn = conn(:get, "/healthcheck_fw_default") |> HealthRouter.call([])
      assert conn.state == :sent
      assert conn.status == @default_response[:ok_status]
      assert conn.resp_body == @default_response[:ok_body]
    end

    test "forward with custom response" do
      conn = conn(:get, "/healthcheck_fw_custom") |> HealthRouter.call([])
      assert conn.state == :sent
      assert conn.status == @custom_response[:ok_status]
      assert conn.resp_body == @custom_response[:ok_body]
    end
  end

  describe ":name option" do
    setup do
      start_supervised!({Existence, state: :ok, name: CustomName})
      :ok
    end

    test "default name" do
      conn = conn(:get, "/") |> Existence.Plug.call([])
      assert conn.status == @default_response[:error_status]
      assert conn.resp_body == @default_response[:error_body]
    end

    test "custom name" do
      conn = conn(:get, "/") |> Existence.Plug.call(name: CustomName)
      assert conn.status == @default_response[:ok_status]
      assert conn.resp_body == @default_response[:ok_body]
    end

    test "invalid name" do
      conn = conn(:get, "/") |> Existence.Plug.call(name: InvalidName)
      assert conn.status == @default_response[:error_status]
      assert conn.resp_body == @default_response[:error_body]
    end
  end

  describe ":raising? option set to true" do
    setup do
      start_supervised!({Existence, state: :ok})
      :ok
    end

    test "it raises on invalid name" do
      assert_raise ArgumentError, fn ->
        conn(:get, "/") |> Existence.Plug.call(name: InvalidName, raising?: true)
      end
    end

    test "it doesn't raise on valid name" do
      conn = conn(:get, "/") |> Existence.Plug.call(raising?: true)
      assert conn.status == @default_response[:ok_status]
      assert conn.resp_body == @default_response[:ok_body]
    end
  end
end
