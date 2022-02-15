defmodule ExistenceTest do
  use ExUnit.Case, async: true
  doctest Existence

  def check_ok(), do: :ok
  def check_error(), do: :error
  def check_timeout(), do: Process.sleep(999_999_999)
  def check_raise(), do: raise("check_raise")
  def check_throw(), do: throw(:check_raise)
  def check_kill(), do: Process.exit(self(), :kill)

  # _____no checks
  describe "no checks, fsm init state: :error" do
    setup do
      start_app([])
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [] == Existence.get_checks()
    end
  end

  describe "no checks, fsm init state: :ok" do
    setup do
      start_app([], :ok)
    end

    test "get_state/0" do
      assert :ok == Existence.get_state()
    end

    test "get_checks/0" do
      assert [] == Existence.get_checks()
    end
  end

  # _____:ok check
  describe "single :ok check, check init state :error, fsm init state: :error" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_ok, []},
          state: :error,
          initial_delay: 0
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :ok == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :ok] == Existence.get_checks()
    end
  end

  describe "single :ok check, check init state :error, fsm init state: :ok" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_ok, []},
          state: :error,
          initial_delay: 0
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :ok == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :ok] == Existence.get_checks()
    end
  end

  describe "single :ok check, check init state :ok, fsm init state: :error" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_ok, []},
          state: :ok,
          initial_delay: 0
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :ok == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :ok] == Existence.get_checks()
    end
  end

  describe "single :ok check, check init state :ok, fsm init state: :ok" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_ok, []},
          state: :ok,
          initial_delay: 0
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :ok == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :ok] == Existence.get_checks()
    end
  end

  # _____:error check
  describe "single :error check, check init state :error, fsm init state: :error" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_error, []},
          state: :error,
          initial_delay: 0
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :error] == Existence.get_checks()
    end
  end

  describe "single :error check, check init state :error, fsm init state: :ok" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_error, []},
          state: :error,
          initial_delay: 0
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :error] == Existence.get_checks()
    end
  end

  describe "single :error check, check init state :ok, fsm init state: :error" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_error, []},
          state: :ok,
          initial_delay: 0
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :error] == Existence.get_checks()
    end
  end

  describe "single :error check, check init state :ok, fsm init state: :ok" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_error, []},
          state: :ok,
          initial_delay: 0
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :error] == Existence.get_checks()
    end
  end

  # _____timeout check
  describe "single timeout check, check init state :error, fsm init state: :error" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_timeout, []},
          initial_delay: 0,
          state: :error,
          timeout: 10
        }
      ]
      |> start_app(:error, 20)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :killed] == Existence.get_checks()
    end
  end

  describe "single timeout check, check init state :error, fsm init state: :ok" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_timeout, []},
          initial_delay: 0,
          state: :error,
          timeout: 10
        }
      ]
      |> start_app(:ok, 20)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :killed] == Existence.get_checks()
    end
  end

  describe "single timeout check, check init state :ok, fsm init state: :error" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_timeout, []},
          initial_delay: 0,
          state: :ok,
          timeout: 10
        }
      ]
      |> start_app(:error, 20)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :killed] == Existence.get_checks()
    end
  end

  describe "single timeout check, check init state :ok, fsm init state: :ok" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_timeout, []},
          initial_delay: 0,
          state: :ok,
          timeout: 10
        }
      ]
      |> start_app(:ok, 20)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :killed] == Existence.get_checks()
    end
  end

  # _____raise check
  describe "single raise check, check init state :error, fsm init state: :error" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_raise, []},
          initial_delay: 0
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: {%RuntimeError{message: "check_raise"}, _stacktrace}] =
               Existence.get_checks()
    end
  end

  describe "single raise check, check init state :error, fsm init state: :ok" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_raise, []},
          initial_delay: 0
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: {%RuntimeError{message: "check_raise"}, _stacktrace}] =
               Existence.get_checks()
    end
  end

  describe "single raise check, check init state :ok, fsm init state: :error" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_raise, []},
          initial_delay: 0,
          state: :ok
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: {%RuntimeError{message: "check_raise"}, _stacktrace}] =
               Existence.get_checks()
    end
  end

  describe "single raise check, check init state :ok, fsm init state: :ok" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_raise, []},
          initial_delay: 0,
          state: :ok
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: {%RuntimeError{message: "check_raise"}, _stacktrace}] =
               Existence.get_checks()
    end
  end

  # _____throw check
  describe "single throw check, check init state :error, fsm init state: :error" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_throw, []},
          initial_delay: 0
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: {{:nocatch, :check_raise}, _stacktrace}] = Existence.get_checks()
    end
  end

  describe "single throw check, check init state :error, fsm init state: :ok" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_throw, []},
          initial_delay: 0
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: {{:nocatch, :check_raise}, _stacktrace}] = Existence.get_checks()
    end
  end

  describe "single throw check, check init state :ok, fsm init state: :error" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_throw, []},
          initial_delay: 0,
          state: :ok
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: {{:nocatch, :check_raise}, _stacktrace}] = Existence.get_checks()
    end
  end

  describe "single throw check, check init state :ok, fsm init state: :ok" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_throw, []},
          initial_delay: 0,
          state: :ok
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: {{:nocatch, :check_raise}, _stacktrace}] = Existence.get_checks()
    end
  end

  # _____kill check
  describe "single kill check, check init state :error, fsm init state: :error" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_kill, []},
          initial_delay: 0
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :killed] == Existence.get_checks()
    end
  end

  describe "single kill check, check init state :error, fsm init state: :ok" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_kill, []},
          initial_delay: 0
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :killed] == Existence.get_checks()
    end
  end

  describe "single kill check, check init state :ok, fsm init state: :error" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_kill, []},
          initial_delay: 0,
          state: :ok
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :killed] == Existence.get_checks()
    end
  end

  describe "single kill check, check init state :ok, fsm init state: :ok" do
    setup do
      [
        check: %{
          mfa: {__MODULE__, :check_kill, []},
          initial_delay: 0,
          state: :ok
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check: :killed] == Existence.get_checks()
    end
  end

  # _____two :ok checks
  describe "two :ok checks, check init states: :error and :error, fsm init state: :error" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :error
        },
        check_2: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :error
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :ok == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :ok, check_2: :ok] == Existence.get_checks() |> Enum.sort()
    end
  end

  describe "two :ok checks, check init states: :ok and :error, fsm init state: :error" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :ok
        },
        check_2: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :error
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :ok == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :ok, check_2: :ok] == Existence.get_checks() |> Enum.sort()
    end
  end

  describe "two :ok checks, check init states: :ok and :ok, fsm init state: :error" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :ok
        },
        check_2: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :ok
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :ok == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :ok, check_2: :ok] == Existence.get_checks() |> Enum.sort()
    end
  end

  describe "two :ok checks, check init states: :error and :error, fsm init state: :ok" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :error
        },
        check_2: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :error
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :ok == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :ok, check_2: :ok] == Existence.get_checks() |> Enum.sort()
    end
  end

  describe "two :ok checks, check init states: :ok and :error, fsm init state: :ok" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :ok
        },
        check_2: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :error
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :ok == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :ok, check_2: :ok] == Existence.get_checks() |> Enum.sort()
    end
  end

  describe "two :ok checks, check init states: :ok and :ok, fsm init state: :ok" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :ok
        },
        check_2: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :ok
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :ok == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :ok, check_2: :ok] == Existence.get_checks() |> Enum.sort()
    end
  end

  # _____two :error checks
  describe "two :error checks, check init states: :error and :error, fsm init state: :error" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :error
        },
        check_2: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :error
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :error, check_2: :error] == Existence.get_checks() |> Enum.sort()
    end
  end

  describe "two :error checks, check init states: :ok and :error, fsm init state: :error" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :ok
        },
        check_2: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :error
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :error, check_2: :error] == Existence.get_checks() |> Enum.sort()
    end
  end

  describe "two :error checks, check init states: :ok and :ok, fsm init state: :error" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :ok
        },
        check_2: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :ok
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :error, check_2: :error] == Existence.get_checks() |> Enum.sort()
    end
  end

  describe "two :error checks, check init states: :error and :error, fsm init state: :ok" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :error
        },
        check_2: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :error
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :error, check_2: :error] == Existence.get_checks() |> Enum.sort()
    end
  end

  describe "two :error checks, check init states: :ok and :error, fsm init state: :ok" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :ok
        },
        check_2: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :error
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :error, check_2: :error] == Existence.get_checks() |> Enum.sort()
    end
  end

  describe "two :error checks, check init states: :ok and :ok, fsm init state: :ok" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :ok
        },
        check_2: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :ok
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :error, check_2: :error] == Existence.get_checks() |> Enum.sort()
    end
  end

  # _____:ok and :error checks
  describe ":ok and :error checks, check init states: :error and :error, fsm init state: :error" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :error
        },
        check_2: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :error
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :ok, check_2: :error] == Existence.get_checks() |> Enum.sort()
    end
  end

  describe ":ok and :error checks, check init states: :ok and :error, fsm init state: :error" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :ok
        },
        check_2: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :error
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :ok, check_2: :error] == Existence.get_checks() |> Enum.sort()
    end
  end

  describe ":ok and :error checks, check init states: :error and :ok, fsm init state: :error" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :error
        },
        check_2: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :ok
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :ok, check_2: :error] == Existence.get_checks() |> Enum.sort()
    end
  end

  describe ":ok and :error checks, check init states: :ok and :ok, fsm init state: :error" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :ok
        },
        check_2: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :ok
        }
      ]
      |> start_app()
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :ok, check_2: :error] == Existence.get_checks() |> Enum.sort()
    end
  end

  describe ":ok and :error checks, check init states: :error and :error, fsm init state: :ok" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :error
        },
        check_2: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :error
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :ok, check_2: :error] == Existence.get_checks() |> Enum.sort()
    end
  end

  describe ":ok and :error checks, check init states: :ok and :error, fsm init state: :ok" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :ok
        },
        check_2: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :error
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :ok, check_2: :error] == Existence.get_checks() |> Enum.sort()
    end
  end

  describe ":ok and :error checks, check init states: :error and :ok, fsm init state: :ok" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :error
        },
        check_2: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :ok
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :ok, check_2: :error] == Existence.get_checks() |> Enum.sort()
    end
  end

  describe ":ok and :error checks, check init states: :ok and :ok, fsm init state: :ok" do
    setup do
      [
        check_1: %{
          mfa: {__MODULE__, :check_ok, []},
          initial_delay: 0,
          state: :ok
        },
        check_2: %{
          mfa: {__MODULE__, :check_error, []},
          initial_delay: 0,
          state: :ok
        }
      ]
      |> start_app(:ok)
    end

    test "get_state/0" do
      assert :error == Existence.get_state()
    end

    test "get_checks/0" do
      assert [check_1: :ok, check_2: :error] == Existence.get_checks() |> Enum.sort()
    end
  end

  defp start_app(config, state \\ :error, init_sleep \\ 10) do
    Application.put_env(:existence, Existence, config)
    start_supervised!({Existence, state: state})
    Process.sleep(init_sleep)
    :ok
  end
end
