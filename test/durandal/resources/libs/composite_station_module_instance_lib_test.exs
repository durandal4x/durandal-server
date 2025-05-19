defmodule Durandal.CompositeStationModuleInstanceLibTest do
  @moduledoc false
  alias Durandal.Resources.CompositeStationModuleInstance
  alias Durandal.Resources
  use Durandal.DataCase, async: true

  alias Durandal.ResourcesFixtures

  defp valid_attrs do
    %{
      type_id: ResourcesFixtures.composite_type_fixture().id,
      ratios: [123, 456],
      quantity: 123,
      combined_mass: 123,
      combined_volume: 123,
      universe_id: Durandal.GameFixtures.universe_fixture().id,
      station_module_id: Durandal.SpaceFixtures.station_module_fixture().id,
      team_id: Durandal.PlayerFixtures.team_fixture().id
    }
  end

  defp update_attrs do
    %{
      type_id: ResourcesFixtures.composite_type_fixture().id,
      ratios: [123, 456, 789],
      quantity: 456,
      combined_mass: 456,
      combined_volume: 456,
      universe_id: Durandal.GameFixtures.universe_fixture().id,
      station_module_id: Durandal.SpaceFixtures.station_module_fixture().id,
      team_id: Durandal.PlayerFixtures.team_fixture().id
    }
  end

  defp invalid_attrs do
    %{
      type_id: nil,
      ratios: nil,
      quantity: nil,
      combined_mass: nil,
      combined_volume: nil,
      universe_id: nil,
      station_module_id: nil,
      team_id: nil
    }
  end

  describe "composite_station_module_instance" do
    alias Durandal.Resources.CompositeStationModuleInstance

    test "composite_station_module_instance_query/0 returns a query" do
      q = Resources.composite_station_module_instance_query([])
      assert %Ecto.Query{} = q
    end

    test "list_composite_station_module_instance/0 returns composite_station_module_instance" do
      # No composite_station_module_instance yet
      assert Resources.list_resources_composite_station_module_instances([]) == []

      # Add a composite_station_module_instance
      ResourcesFixtures.composite_station_module_instance_fixture()
      assert Resources.list_resources_composite_station_module_instances([]) != []
    end

    test "get_composite_station_module_instance!/1 and get_composite_station_module_instance/1 returns the composite_station_module_instance with given id" do
      composite_station_module_instance =
        ResourcesFixtures.composite_station_module_instance_fixture()

      assert Resources.get_composite_station_module_instance!(
               composite_station_module_instance.id
             ) == composite_station_module_instance

      assert Resources.get_composite_station_module_instance(composite_station_module_instance.id) ==
               composite_station_module_instance
    end

    test "create_composite_station_module_instance/1 with valid data creates a composite_station_module_instance" do
      assert {:ok, %CompositeStationModuleInstance{} = composite_station_module_instance} =
               Resources.create_composite_station_module_instance(valid_attrs())

      assert composite_station_module_instance.ratios == [123, 456]
      assert composite_station_module_instance.quantity == 123
      assert composite_station_module_instance.combined_mass == 123
      assert composite_station_module_instance.combined_volume == 123
    end

    test "create_composite_station_module_instance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Resources.create_composite_station_module_instance(invalid_attrs())
    end

    test "update_composite_station_module_instance/2 with valid data updates the composite_station_module_instance" do
      composite_station_module_instance =
        ResourcesFixtures.composite_station_module_instance_fixture()

      assert {:ok, %CompositeStationModuleInstance{} = composite_station_module_instance} =
               Resources.update_composite_station_module_instance(
                 composite_station_module_instance,
                 update_attrs()
               )

      assert composite_station_module_instance.ratios == [123, 456, 789]
      assert composite_station_module_instance.quantity == 456
      assert composite_station_module_instance.combined_mass == 456
      assert composite_station_module_instance.combined_volume == 456
    end

    test "update_composite_station_module_instance/2 with invalid data returns error changeset" do
      composite_station_module_instance =
        ResourcesFixtures.composite_station_module_instance_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Resources.update_composite_station_module_instance(
                 composite_station_module_instance,
                 invalid_attrs()
               )

      assert composite_station_module_instance ==
               Resources.get_composite_station_module_instance!(
                 composite_station_module_instance.id
               )
    end

    test "delete_composite_station_module_instance/1 deletes the composite_station_module_instance" do
      composite_station_module_instance =
        ResourcesFixtures.composite_station_module_instance_fixture()

      assert {:ok, %CompositeStationModuleInstance{}} =
               Resources.delete_composite_station_module_instance(
                 composite_station_module_instance
               )

      assert_raise Ecto.NoResultsError, fn ->
        Resources.get_composite_station_module_instance!(composite_station_module_instance.id)
      end

      assert Resources.get_composite_station_module_instance(composite_station_module_instance.id) ==
               nil
    end

    test "change_composite_station_module_instance/1 returns a composite_station_module_instance changeset" do
      composite_station_module_instance =
        ResourcesFixtures.composite_station_module_instance_fixture()

      assert %Ecto.Changeset{} =
               Resources.change_composite_station_module_instance(
                 composite_station_module_instance
               )
    end
  end
end
