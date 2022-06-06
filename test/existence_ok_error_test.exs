defmodule Existence.OkErrorTest do
  use ExUnit.Case

  import ExistenceTest.Common

  def check_1(), do: :ok
  def check_2(), do: :error
  @state :error

  describe "checks: defaults, fsm_state: default" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0
          }
        ]
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :ok/default, fsm_state: default" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :ok
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0
          }
        ]
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :ok/:ok, fsm_state: default" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :ok
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :ok
          }
        ]
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :ok/:error, fsm_state: default" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :ok
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :error
          }
        ]
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :ok/:custom_error, fsm_state: default" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :ok
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :custom_error
          }
        ]
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :error/default, fsm_state: default" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0
          }
        ]
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :error/:ok, fsm_state: default" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :ok
          }
        ]
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :error/:error, fsm_state: default" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :error
          }
        ]
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :error/:custom_error, fsm_state: default" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :custom_error
          }
        ]
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :custom_error/default, fsm_state: default" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :custom_error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0
          }
        ]
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :custom_error/:ok, fsm_state: default" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :custom_error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :ok
          }
        ]
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :custom_error/:error, fsm_state: default" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :custom_error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :error
          }
        ]
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :custom_error/:custom_error, fsm_state: default" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :custom_error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :custom_error
          }
        ]
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: defaults, fsm_state: :ok" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0
          }
        ],
        state: :ok
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :ok/default, fsm_state: :ok" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :ok
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0
          }
        ],
        state: :ok
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :ok/:ok, fsm_state: :ok" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :ok
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :ok
          }
        ],
        state: :ok
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :ok/:error, fsm_state: :ok" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :ok
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :error
          }
        ],
        state: :ok
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :ok/:custom_error, fsm_state: :ok" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :ok
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :custom_error
          }
        ],
        state: :ok
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :error/default, fsm_state: :ok" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0
          }
        ],
        state: :ok
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :error/:ok, fsm_state: :ok" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :ok
          }
        ],
        state: :ok
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :error/:error, fsm_state: :ok" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :error
          }
        ],
        state: :ok
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :error/:custom_error, fsm_state: :ok" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :custom_error
          }
        ],
        state: :ok
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :custom_error/default, fsm_state: :ok" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :custom_error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0
          }
        ],
        state: :ok
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :custom_error/:ok, fsm_state: :ok" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :custom_error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :ok
          }
        ],
        state: :ok
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :custom_error/:error, fsm_state: :ok" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :custom_error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :error
          }
        ],
        state: :ok
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :custom_error/:custom_error, fsm_state: :ok" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :custom_error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :custom_error
          }
        ],
        state: :ok
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: defaults, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0
          }
        ],
        state: :custom_error
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :ok/default, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :ok
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0
          }
        ],
        state: :custom_error
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :ok/:ok, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :ok
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :ok
          }
        ],
        state: :custom_error
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :ok/:error, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :ok
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :error
          }
        ],
        state: :custom_error
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :ok/:custom_error, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :ok
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :custom_error
          }
        ],
        state: :custom_error
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :error/default, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0
          }
        ],
        state: :custom_error
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :error/:ok, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :ok
          }
        ],
        state: :custom_error
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :error/:error, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :error
          }
        ],
        state: :custom_error
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :error/:custom_error, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :custom_error
          }
        ],
        state: :custom_error
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :custom_error/default, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :custom_error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0
          }
        ],
        state: :custom_error
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :custom_error/:ok, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :custom_error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :ok
          }
        ],
        state: :custom_error
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :custom_error/:error, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :custom_error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :error
          }
        ],
        state: :custom_error
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end

  describe "checks: :custom_error/:custom_error, fsm_state: :custom_error" do
    setup do
      [
        checks: [
          check_1: %{
            mfa: {__MODULE__, :check_1, []},
            initial_delay: 0,
            state: :custom_error
          },
          check_2: %{
            mfa: {__MODULE__, :check_2, []},
            initial_delay: 0,
            state: :custom_error
          }
        ],
        state: :custom_error
      ]
      |> start()
    end

    test "get_state/0" do
      assert @state == Existence.get_state()
    end

    test "get_state!/0" do
      assert @state == Existence.get_state!()
    end

    test "get_checks/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks() |> Enum.sort()
    end

    test "get_checks!/0" do
      assert [check_1: check_1(), check_2: check_2()] == Existence.get_checks!() |> Enum.sort()
    end
  end
end
