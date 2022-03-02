defmodule ExistenceTest do
  use ExUnit.Case

  import ExistenceTest.Common

  @ets_error "errors were found at the given arguments:\n\n  * 1st argument: the table identifier does not refer to an existing ETS table\n"

  describe("child_spec/1") do
    test "defaults are correct" do
      assert %{id: Existence, start: {Existence, :start_link, [[]]}} ==
               Existence.child_spec([])
    end

    test "custom :id" do
      assert %{
               id: CustomID,
               start: {Existence, :start_link, [[]]}
             } == Existence.child_spec(id: CustomID)
    end

    test "custom name: CustomName" do
      assert %{
               id: Existence,
               start: {Existence, :start_link, [[name: CustomName]]}
             } == Existence.child_spec(name: CustomName)
    end

    test "custom name: {:local, CustomName}" do
      assert %{
               id: Existence,
               start: {Existence, :start_link, [[name: {:local, CustomName}]]}
             } == Existence.child_spec(name: {:local, CustomName})
    end

    test "custom :state" do
      assert %{
               id: Existence,
               start: {Existence, :start_link, [[{:state, :custom}]]}
             } ==
               Existence.child_spec(state: :custom)
    end

    test "custom :id, name: CustomName and :state" do
      assert %{
               id: CustomID,
               start: {Existence, :start_link, [[{:name, CustomName}, {:state, :custom}]]}
             } ==
               Existence.child_spec(id: CustomID, name: CustomName, state: :custom)
    end

    test "custom :id, name: {:local, CustomName} and :state" do
      assert %{
               id: CustomID,
               start:
                 {Existence, :start_link, [[{:name, {:local, CustomName}}, {:state, :custom}]]}
             } ==
               Existence.child_spec(id: CustomID, name: {:local, CustomName}, state: :custom)
    end

    test "check is defined" do
      assert %{
               id: Existence,
               start:
                 {Existence, :start_link,
                  [
                    [
                      {:checks, [check_1: %{mfa: {HealthCheck.Checks, :check_1, []}}]}
                    ]
                  ]}
             } ==
               Existence.child_spec(
                 checks: [
                   check_1: %{
                     mfa: {HealthCheck.Checks, :check_1, []}
                   }
                 ]
               )
    end
  end

  describe "Existence is not started" do
    test "get_state/1" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state() end
    end

    test "get_checks/1" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_checks() end
    end
  end

  describe "all defaults" do
    setup do
      start([])
    end

    test "get_state/1, default name" do
      assert :error == Existence.get_state()
    end

    test "get_checks/1, default name" do
      assert [] == Existence.get_checks()
    end

    test "get_state/1, valid name" do
      assert :error == Existence.get_state(Existence)
    end

    test "get_checks/1, valid name" do
      assert [] == Existence.get_checks(Existence)
    end

    test "get_state/1, invalid name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state(Invalid) end
    end

    test "get_checks/1, invalid name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state(Invalid) end
    end
  end

  describe "custom :id" do
    setup do
      start(id: CustomID)
    end

    test "get_state/1, default name" do
      assert :error == Existence.get_state()
    end

    test "get_checks/1, default name" do
      assert [] == Existence.get_checks()
    end

    test "get_state/1, valid name" do
      assert :error == Existence.get_state(Existence)
    end

    test "get_checks/1, valid name" do
      assert [] == Existence.get_checks(Existence)
    end

    test "get_state/1, invalid name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state(Invalid) end
    end

    test "get_checks/1, invalid name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state(Invalid) end
    end
  end

  describe "custom name: CustomName" do
    setup do
      start(name: CustomName)
    end

    test "get_state/1, default name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state() end
    end

    test "get_checks/1, default name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state() end
    end

    test "get_state/1, valid name" do
      assert :error == Existence.get_state(CustomName)
    end

    test "get_checks/1, valid name" do
      assert [] == Existence.get_checks(CustomName)
    end

    test "get_state/1, invalid name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state(Invalid) end
    end

    test "get_checks/1, invalid name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state(Invalid) end
    end
  end

  describe "custom name: {:local, CustomName}" do
    setup do
      start(name: {:local, CustomName})
    end

    test "get_state/1, default name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state() end
    end

    test "get_checks/1, default name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state() end
    end

    test "get_state/1, valid name" do
      assert :error == Existence.get_state(CustomName)
    end

    test "get_checks/1, valid name" do
      assert [] == Existence.get_checks(CustomName)
    end

    test "get_state/1, invalid name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state(Invalid) end
    end

    test "get_checks/1, invalid name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state(Invalid) end
    end
  end

  describe "custom state: :custom_error" do
    setup do
      start(state: :custom_error)
    end

    test "get_state/1, default name" do
      assert :error == Existence.get_state()
    end

    test "get_checks/1, default name" do
      assert [] == Existence.get_checks()
    end

    test "get_state/1, valid name" do
      assert :error == Existence.get_state(Existence)
    end

    test "get_checks/1, valid name" do
      assert [] == Existence.get_checks(Existence)
    end

    test "get_state/1, invalid name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state(Invalid) end
    end

    test "get_checks/1, invalid name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state(Invalid) end
    end
  end

  describe "custom state: :ok" do
    setup do
      start(state: :ok)
    end

    test "get_state/1, default name" do
      assert :ok == Existence.get_state()
    end

    test "get_checks/1, default name" do
      assert [] == Existence.get_checks()
    end

    test "get_state/1, valid name" do
      assert :ok == Existence.get_state(Existence)
    end

    test "get_checks/1, valid name" do
      assert [] == Existence.get_checks(Existence)
    end

    test "get_state/1, invalid name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state(Invalid) end
    end

    test "get_checks/1, invalid name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state(Invalid) end
    end
  end

  describe "custom :id, name: CustomName and state: :ok" do
    setup do
      start(id: CustomID, name: CustomName, state: :ok)
    end

    test "get_state/1, default name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state() end
    end

    test "get_checks/1, default name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state() end
    end

    test "get_state/1, valid name" do
      assert :ok == Existence.get_state(CustomName)
    end

    test "get_checks/1, valid name" do
      assert [] == Existence.get_checks(CustomName)
    end

    test "get_state/1, invalid name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state(Invalid) end
    end

    test "get_checks/1, invalid name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state(Invalid) end
    end
  end

  describe "custom :id, name: {:local, CustomName} and state: :ok" do
    setup do
      start(id: CustomID, name: {:local, CustomName}, state: :ok)
    end

    test "get_state/1, default name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state() end
    end

    test "get_checks/1, default name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state() end
    end

    test "get_state/1, valid name" do
      assert :ok == Existence.get_state(CustomName)
    end

    test "get_checks/1, valid name" do
      assert [] == Existence.get_checks(CustomName)
    end

    test "get_state/1, invalid name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state(Invalid) end
    end

    test "get_checks/1, invalid name" do
      assert_raise ArgumentError, @ets_error, fn -> Existence.get_state(Invalid) end
    end
  end
end
