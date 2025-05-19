defmodule Durandal.CompositeShipInstanceLibTest do
  @moduledoc false
  alias Durandal.Resources.CompositeShipInstance
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
      ship_id: Durandal.SpaceFixtures.ship_fixture().id,
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
      ship_id: Durandal.SpaceFixtures.ship_fixture().id,
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
      ship_id: nil,
      team_id: nil
    }
  end

  describe "composite_ship_instance" do
    alias Durandal.Resources.CompositeShipInstance

    test "composite_ship_instance_query/0 returns a query" do
      q = Resources.composite_ship_instance_query([])
      assert %Ecto.Query{} = q
    end

    test "list_composite_ship_instance/0 returns composite_ship_instance" do
      # No composite_ship_instance yet
      assert Resources.list_resources_composite_ship_instances([]) == []

      # Add a composite_ship_instance
      ResourcesFixtures.composite_ship_instance_fixture()
      assert Resources.list_resources_composite_ship_instances([]) != []
    end

    test "get_composite_ship_instance!/1 and get_composite_ship_instance/1 returns the composite_ship_instance with given id" do
      composite_ship_instance = ResourcesFixtures.composite_ship_instance_fixture()

      assert Resources.get_composite_ship_instance!(composite_ship_instance.id) ==
               composite_ship_instance

      assert Resources.get_composite_ship_instance(composite_ship_instance.id) ==
               composite_ship_instance
    end

    test "create_composite_ship_instance/1 with valid data creates a composite_ship_instance" do
      assert {:ok, %CompositeShipInstance{} = composite_ship_instance} =
               Resources.create_composite_ship_instance(valid_attrs())

      assert composite_ship_instance.ratios == [123, 456]
      assert composite_ship_instance.quantity == 123
      assert composite_ship_instance.combined_mass == 123
      assert composite_ship_instance.combined_volume == 123
    end

    test "create_composite_ship_instance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Resources.create_composite_ship_instance(invalid_attrs())
    end

    test "update_composite_ship_instance/2 with valid data updates the composite_ship_instance" do
      composite_ship_instance = ResourcesFixtures.composite_ship_instance_fixture()

      assert {:ok, %CompositeShipInstance{} = composite_ship_instance} =
               Resources.update_composite_ship_instance(composite_ship_instance, update_attrs())

      assert composite_ship_instance.ratios == [123, 456, 789]
      assert composite_ship_instance.quantity == 456
      assert composite_ship_instance.combined_mass == 456
      assert composite_ship_instance.combined_volume == 456
    end

    test "update_composite_ship_instance/2 with invalid data returns error changeset" do
      composite_ship_instance = ResourcesFixtures.composite_ship_instance_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Resources.update_composite_ship_instance(composite_ship_instance, invalid_attrs())

      assert composite_ship_instance ==
               Resources.get_composite_ship_instance!(composite_ship_instance.id)
    end

    test "delete_composite_ship_instance/1 deletes the composite_ship_instance" do
      composite_ship_instance = ResourcesFixtures.composite_ship_instance_fixture()

      assert {:ok, %CompositeShipInstance{}} =
               Resources.delete_composite_ship_instance(composite_ship_instance)

      assert_raise Ecto.NoResultsError, fn ->
        Resources.get_composite_ship_instance!(composite_ship_instance.id)
      end

      assert Resources.get_composite_ship_instance(composite_ship_instance.id) == nil
    end

    test "change_composite_ship_instance/1 returns a composite_ship_instance changeset" do
      composite_ship_instance = ResourcesFixtures.composite_ship_instance_fixture()
      assert %Ecto.Changeset{} = Resources.change_composite_ship_instance(composite_ship_instance)
    end
  end
end
