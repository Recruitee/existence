defmodule Existence.DynamicTest do
  use ExUnit.Case

  import ExistenceTest.Common

  def check_1(), do: :persistent_term.get(:check_1, :ok)
  def check_2(), do: :persistent_term.get(:check_2, :ok)
  def on_state_change(state, "args"), do: :persistent_term.put(:on_state_change, state)

  setup do
    :ok = reset_on_state_changed()

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
      ],
      on_state_change: {__MODULE__, :on_state_change, "args"}
    ]
    |> start()
  end

  defp get_on_state_changed(), do: :persistent_term.get(:on_state_change)
  defp reset_on_state_changed(), do: :persistent_term.put(:on_state_change, nil)

  test "returns valid overall state and valid checks states on dynamic checks changes" do
    assert :ok == Existence.get_state()
    assert :ok == Existence.get_state!()
    assert [check_1: :ok, check_2: :ok] == Existence.get_checks() |> Enum.sort()
    assert [check_1: :ok, check_2: :ok] == Existence.get_checks!() |> Enum.sort()
    assert :ok == get_on_state_changed()

    :ok = reset_on_state_changed()
    :ok = :persistent_term.put(:check_1, :error)
    Process.sleep(20)
    assert :error == Existence.get_state()
    assert :error == Existence.get_state!()
    assert [check_1: :error, check_2: :ok] == Existence.get_checks() |> Enum.sort()
    assert [check_1: :error, check_2: :ok] == Existence.get_checks!() |> Enum.sort()
    assert :error == get_on_state_changed()

    :ok = reset_on_state_changed()
    :ok = :persistent_term.put(:check_2, :error)
    Process.sleep(20)
    assert :error == Existence.get_state()
    assert :error == Existence.get_state!()
    assert [check_1: :error, check_2: :error] == Existence.get_checks() |> Enum.sort()
    assert [check_1: :error, check_2: :error] == Existence.get_checks!() |> Enum.sort()
    assert nil == get_on_state_changed()

    :ok = reset_on_state_changed()
    :ok = :persistent_term.put(:check_1, :ok)
    Process.sleep(20)
    assert :error == Existence.get_state()
    assert :error == Existence.get_state!()
    assert [check_1: :ok, check_2: :error] == Existence.get_checks() |> Enum.sort()
    assert [check_1: :ok, check_2: :error] == Existence.get_checks!() |> Enum.sort()
    assert nil == get_on_state_changed()

    :ok = reset_on_state_changed()
    :ok = :persistent_term.put(:check_2, :ok)
    Process.sleep(20)
    assert :ok == Existence.get_state()
    assert :ok == Existence.get_state!()
    assert [check_1: :ok, check_2: :ok] == Existence.get_checks() |> Enum.sort()
    assert [check_1: :ok, check_2: :ok] == Existence.get_checks!() |> Enum.sort()
    assert :ok == get_on_state_changed()
  end
end
