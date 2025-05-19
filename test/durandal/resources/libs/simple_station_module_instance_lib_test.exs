defmodule Durandal.SimpleStationModuleInstanceLibTest do
  @moduledoc false
  alias Durandal.Resources.SimpleStationModuleInstance
  alias Durandal.Resources
  use Durandal.DataCase, async: true

  alias Durandal.ResourcesFixtures

  defp valid_attrs do
    %{
      type_id: ResourcesFixtures.simple_type_fixture().id,
      quantity: 123,
      universe_id: Durandal.GameFixtures.universe_fixture().id,
      station_module_id: Durandal.SpaceFixtures.station_module_fixture().id,
      team_id: Durandal.PlayerFixtures.team_fixture().id
    }
  end

  defp update_attrs do
    %{
      type_id: ResourcesFixtures.simple_type_fixture().id,
      quantity: 456,
      universe_id: Durandal.GameFixtures.universe_fixture().id,
      station_module_id: Durandal.SpaceFixtures.station_module_fixture().id,
      team_id: Durandal.PlayerFixtures.team_fixture().id
    }
  end

  defp invalid_attrs do
    %{
      type_id: nil,
      quantity: nil,
      universe_id: nil,
      station_module_id: nil,
      team_id: nil
    }
  end

  describe "simple_station_module_instance" do
    alias Durandal.Resources.SimpleStationModuleInstance

    test "simple_station_module_instance_query/0 returns a query" do
      q = Resources.simple_station_module_instance_query([])
      assert %Ecto.Query{} = q
    end

    test "list_simple_station_module_instance/0 returns simple_station_module_instance" do
      # No simple_station_module_instance yet
      assert Resources.list_resources_simple_station_module_instances([]) == []

      # Add a simple_station_module_instance
      ResourcesFixtures.simple_station_module_instance_fixture()
      assert Resources.list_resources_simple_station_module_instances([]) != []
    end

    test "get_simple_station_module_instance!/1 and get_simple_station_module_instance/1 returns the simple_station_module_instance with given id" do
      simple_station_module_instance = ResourcesFixtures.simple_station_module_instance_fixture()

      assert Resources.get_simple_station_module_instance!(simple_station_module_instance.id) ==
               simple_station_module_instance

      assert Resources.get_simple_station_module_instance(simple_station_module_instance.id) ==
               simple_station_module_instance
    end

    test "create_simple_station_module_instance/1 with valid data creates a simple_station_module_instance" do
      assert {:ok, %SimpleStationModuleInstance{} = simple_station_module_instance} =
               Resources.create_simple_station_module_instance(valid_attrs())

      assert simple_station_module_instance.quantity == 123
    end

    test "create_simple_station_module_instance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Resources.create_simple_station_module_instance(invalid_attrs())
    end

    test "update_simple_station_module_instance/2 with valid data updates the simple_station_module_instance" do
      simple_station_module_instance = ResourcesFixtures.simple_station_module_instance_fixture()

      assert {:ok, %SimpleStationModuleInstance{} = simple_station_module_instance} =
               Resources.update_simple_station_module_instance(
                 simple_station_module_instance,
                 update_attrs()
               )

      assert simple_station_module_instance.quantity == 456
    end

    test "update_simple_station_module_instance/2 with invalid data returns error changeset" do
      simple_station_module_instance = ResourcesFixtures.simple_station_module_instance_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Resources.update_simple_station_module_instance(
                 simple_station_module_instance,
                 invalid_attrs()
               )

      assert simple_station_module_instance ==
               Resources.get_simple_station_module_instance!(simple_station_module_instance.id)
    end

    test "delete_simple_station_module_instance/1 deletes the simple_station_module_instance" do
      simple_station_module_instance = ResourcesFixtures.simple_station_module_instance_fixture()

      assert {:ok, %SimpleStationModuleInstance{}} =
               Resources.delete_simple_station_module_instance(simple_station_module_instance)

      assert_raise Ecto.NoResultsError, fn ->
        Resources.get_simple_station_module_instance!(simple_station_module_instance.id)
      end

      assert Resources.get_simple_station_module_instance(simple_station_module_instance.id) ==
               nil
    end

    test "change_simple_station_module_instance/1 returns a simple_station_module_instance changeset" do
      simple_station_module_instance = ResourcesFixtures.simple_station_module_instance_fixture()

      assert %Ecto.Changeset{} =
               Resources.change_simple_station_module_instance(simple_station_module_instance)
    end
  end
end
