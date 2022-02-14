defmodule Existence.GenCheckTest do
  use ExUnit.Case, async: true

  alias Existence.GenCheck

  setup do
    config = [
      check: %{
        mfa: {__MODULE__, fn -> :error end, []},
        initial_delay: 0
      }
    ]

    Application.put_env(:existence, Existence, config)
    start_supervised!(Existence)
    Process.sleep(10)
    :ok
  end

  test "get_state/0" do
    assert :error == GenCheck.get_state()
  end

  test "get_checks/0" do
    assert [:check] = GenCheck.get_checks()
  end

  test "get_check_state/1" do
    assert :error == GenCheck.get_check_state(:check)

    assert_raise MatchError, "no match of right hand side value: []", fn ->
      GenCheck.get_check_state(:not_existing)
    end
  end

  test "child_spec/1" do
    assert %{id: Existence.GenCheck, start: {Existence.GenCheck, :start_link, [[]]}} ==
             GenCheck.child_spec([])

    assert %{id: Existence.GenCheck, start: {Existence.GenCheck, :start_link, [[state: :ok]]}} ==
             GenCheck.child_spec(state: :ok)
  end

  test "unhealthy/3 :enter" do
    assert :keep_state_and_data == GenCheck.unhealthy(:enter, :unhealthy, [])
    assert :keep_state_and_data == GenCheck.unhealthy(:enter, :healthy, [])
  end

  test "healthy/3 :enter" do
    assert :keep_state_and_data == GenCheck.healthy(:enter, :unhealthy, [])
    assert :keep_state_and_data == GenCheck.healthy(:enter, :healthy, [])
  end
end
