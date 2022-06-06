defmodule Existence.DynamicTest do
  use ExUnit.Case

  import ExistenceTest.Common

  def check_1(), do: :persistent_term.get(:check_1, :ok)
  def check_2(), do: :persistent_term.get(:check_2, :ok)

  setup do
    [
      checks: [
        check_1: %{
          mfa: {__MODULE__, :check_1, []},
          initial_delay: 0,
          interval: 10
        },
        check_2: %{
          mfa: {__MODULE__, :check_2, []},
          initial_delay: 0,
          interval: 10
        }
      ]
    ]
    |> start()
  end

  test "returns valid overall state and valid checks states on dynamic checks changes" do
    assert :ok == Existence.get_state()
    assert :ok == Existence.get_state!()
    assert [check_1: :ok, check_2: :ok] == Existence.get_checks() |> Enum.sort()
    assert [check_1: :ok, check_2: :ok] == Existence.get_checks!() |> Enum.sort()

    :persistent_term.put(:check_1, :error)
    Process.sleep(20)
    assert :error == Existence.get_state()
    assert :error == Existence.get_state!()
    assert [check_1: :error, check_2: :ok] == Existence.get_checks() |> Enum.sort()
    assert [check_1: :error, check_2: :ok] == Existence.get_checks!() |> Enum.sort()

    :persistent_term.put(:check_2, :error)
    Process.sleep(20)
    assert :error == Existence.get_state()
    assert :error == Existence.get_state!()
    assert [check_1: :error, check_2: :error] == Existence.get_checks() |> Enum.sort()
    assert [check_1: :error, check_2: :error] == Existence.get_checks!() |> Enum.sort()

    :persistent_term.put(:check_1, :ok)
    Process.sleep(20)
    assert :error == Existence.get_state()
    assert :error == Existence.get_state!()
    assert [check_1: :ok, check_2: :error] == Existence.get_checks() |> Enum.sort()
    assert [check_1: :ok, check_2: :error] == Existence.get_checks!() |> Enum.sort()

    :persistent_term.put(:check_2, :ok)
    Process.sleep(20)
    assert :ok == Existence.get_state()
    assert :ok == Existence.get_state!()
    assert [check_1: :ok, check_2: :ok] == Existence.get_checks() |> Enum.sort()
    assert [check_1: :ok, check_2: :ok] == Existence.get_checks!() |> Enum.sort()
  end
end
