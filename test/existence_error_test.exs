defmodule Existence.ErrorTest do
  use ExUnit.Case

  import ExistenceTest.Common

  def check(), do: :error

  describe "check: defaults, fsm_state: default" do
    setup do
      [
        checks: [
          check: %{
            mfa: {__MODULE__, :check, []},
            initial_delay: 0
          }
        ]
      ]
      |> start()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :error] == Existence.get_checks()
    end
  end

  describe "check: state: :ok, fsm_state: default" do
    setup do
      [
        checks: [
          check: %{
            mfa: {__MODULE__, :check, []},
            initial_delay: 0,
            state: :ok
          }
        ]
      ]
      |> start()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :error] == Existence.get_checks()
    end
  end

  describe "check: state: :custom_error, fsm_state: default" do
    setup do
      [
        checks: [
          check: %{
            mfa: {__MODULE__, :check, []},
            initial_delay: 0,
            state: :custom_error
          }
        ]
      ]
      |> start()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :error] == Existence.get_checks()
    end
  end

  describe "check: defaults, fsm_state: :ok" do
    setup do
      [
        checks: [
          check: %{
            mfa: {__MODULE__, :check, []},
            initial_delay: 0
          }
        ],
        state: :ok
      ]
      |> start()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :error] == Existence.get_checks()
    end
  end

  describe "check: state: :ok, fsm_state: :ok" do
    setup do
      [
        checks: [
          check: %{
            mfa: {__MODULE__, :check, []},
            initial_delay: 0,
            state: :ok
          }
        ],
        state: :ok
      ]
      |> start()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :error] == Existence.get_checks()
    end
  end

  describe "check: state: :custom_error, fsm_state: :ok" do
    setup do
      [
        checks: [
          check: %{
            mfa: {__MODULE__, :check, []},
            initial_delay: 0,
            state: :custom_error
          }
        ],
        state: :ok
      ]
      |> start()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :error] == Existence.get_checks()
    end
  end

  describe "check: defaults, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check: %{
            mfa: {__MODULE__, :check, []},
            initial_delay: 0
          }
        ],
        state: :custom_error
      ]
      |> start()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :error] == Existence.get_checks()
    end
  end

  describe "check: state: :ok, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check: %{
            mfa: {__MODULE__, :check, []},
            initial_delay: 0,
            state: :ok
          }
        ],
        state: :custom_error
      ]
      |> start()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :error] == Existence.get_checks()
    end
  end

  describe "check: state: :custom_error, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check: %{
            mfa: {__MODULE__, :check, []},
            initial_delay: 0,
            state: :custom_error
          }
        ],
        state: :custom_error
      ]
      |> start()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :error] == Existence.get_checks()
    end
  end
end
