defmodule Existence.TimeoutTest do
  use ExUnit.Case

  import ExistenceTest.Common

  def check(), do: Process.sleep(999_999_999)

  describe "check: defaults, fsm_state: default" do
    setup do
      [
        checks: [
          check: %{
            mfa: {__MODULE__, :check, []},
            initial_delay: 0,
            timeout: 10
          }
        ]
      ]
      |> start(20)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_state!/0" do
      assert :error == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check: :killed] == Existence.get_checks()
    end

    test "get_checks!/0" do
      assert [check: :killed] == Existence.get_checks!()
    end
  end

  describe "check: state: :ok, fsm_state: default" do
    setup do
      [
        checks: [
          check: %{
            mfa: {__MODULE__, :check, []},
            initial_delay: 0,
            state: :ok,
            timeout: 10
          }
        ]
      ]
      |> start(20)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_state!/0" do
      assert :error == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check: :killed] == Existence.get_checks()
    end

    test "get_checks!/0" do
      assert [check: :killed] == Existence.get_checks!()
    end
  end

  describe "check: state: :custom_error, fsm_state: default" do
    setup do
      [
        checks: [
          check: %{
            mfa: {__MODULE__, :check, []},
            initial_delay: 0,
            state: :custom_error,
            timeout: 10
          }
        ]
      ]
      |> start(20)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_state!/0" do
      assert :error == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check: :killed] == Existence.get_checks()
    end

    test "get_checks!/0" do
      assert [check: :killed] == Existence.get_checks!()
    end
  end

  describe "check: defaults, fsm_state: :ok" do
    setup do
      [
        checks: [
          check: %{
            mfa: {__MODULE__, :check, []},
            initial_delay: 0,
            timeout: 10
          }
        ],
        state: :ok
      ]
      |> start(20)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_state!/0" do
      assert :error == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check: :killed] == Existence.get_checks()
    end

    test "get_checks!/0" do
      assert [check: :killed] == Existence.get_checks!()
    end
  end

  describe "check: state: :ok, fsm_state: :ok" do
    setup do
      [
        checks: [
          check: %{
            mfa: {__MODULE__, :check, []},
            initial_delay: 0,
            state: :ok,
            timeout: 10
          }
        ],
        state: :ok
      ]
      |> start(20)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_state!/0" do
      assert :error == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check: :killed] == Existence.get_checks()
    end

    test "get_checks!/0" do
      assert [check: :killed] == Existence.get_checks!()
    end
  end

  describe "check: state: :custom_error, fsm_state: :ok" do
    setup do
      [
        checks: [
          check: %{
            mfa: {__MODULE__, :check, []},
            initial_delay: 0,
            state: :custom_error,
            timeout: 10
          }
        ],
        state: :ok
      ]
      |> start(20)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_state!/0" do
      assert :error == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check: :killed] == Existence.get_checks()
    end

    test "get_checks!/0" do
      assert [check: :killed] == Existence.get_checks!()
    end
  end

  describe "check: defaults, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check: %{
            mfa: {__MODULE__, :check, []},
            initial_delay: 0,
            timeout: 10
          }
        ],
        state: :custom_error
      ]
      |> start(20)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_state!/0" do
      assert :error == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check: :killed] == Existence.get_checks()
    end

    test "get_checks!/0" do
      assert [check: :killed] == Existence.get_checks!()
    end
  end

  describe "check: state: :ok, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check: %{
            mfa: {__MODULE__, :check, []},
            initial_delay: 0,
            state: :ok,
            timeout: 10
          }
        ],
        state: :custom_error
      ]
      |> start(20)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_state!/0" do
      assert :error == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check: :killed] == Existence.get_checks()
    end

    test "get_checks!/0" do
      assert [check: :killed] == Existence.get_checks!()
    end
  end

  describe "check: state: :custom_error, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check: %{
            mfa: {__MODULE__, :check, []},
            initial_delay: 0,
            state: :custom_error,
            timeout: 10
          }
        ],
        state: :custom_error
      ]
      |> start(20)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_state!/0" do
      assert :error == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check: :killed] == Existence.get_checks()
    end

    test "get_checks!/0" do
      assert [check: :killed] == Existence.get_checks!()
    end
  end
end
