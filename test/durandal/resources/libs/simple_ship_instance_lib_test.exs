defmodule Durandal.SimpleShipInstanceLibTest do
  @moduledoc false
  alias Durandal.Resources.SimpleShipInstance
  alias Durandal.Resources
  use Durandal.DataCase, async: true

  alias Durandal.ResourcesFixtures

  defp valid_attrs do
    %{
      type_id: ResourcesFixtures.simple_type_fixture().id,
      quantity: 123,
      universe_id: Durandal.GameFixtures.universe_fixture().id,
      ship_id: Durandal.SpaceFixtures.ship_fixture().id,
      team_id: Durandal.PlayerFixtures.team_fixture().id
    }
  end

  defp update_attrs do
    %{
      type_id: ResourcesFixtures.simple_type_fixture().id,
      quantity: 456,
      universe_id: Durandal.GameFixtures.universe_fixture().id,
      ship_id: Durandal.SpaceFixtures.ship_fixture().id,
      team_id: Durandal.PlayerFixtures.team_fixture().id
    }
  end

  defp invalid_attrs do
    %{
      type_id: nil,
      quantity: nil,
      universe_id: nil,
      ship_id: nil,
      team_id: nil
    }
  end

  describe "simple_ship_instance" do
    alias Durandal.Resources.SimpleShipInstance

    test "simple_ship_instance_query/0 returns a query" do
      q = Resources.simple_ship_instance_query([])
      assert %Ecto.Query{} = q
    end

    test "list_simple_ship_instance/0 returns simple_ship_instance" do
      # No simple_ship_instance yet
      assert Resources.list_resources_simple_ship_instances([]) == []

      # Add a simple_ship_instance
      ResourcesFixtures.simple_ship_instance_fixture()
      assert Resources.list_resources_simple_ship_instances([]) != []
    end

    test "get_simple_ship_instance!/1 and get_simple_ship_instance/1 returns the simple_ship_instance with given id" do
      simple_ship_instance = ResourcesFixtures.simple_ship_instance_fixture()
      assert Resources.get_simple_ship_instance!(simple_ship_instance.id) == simple_ship_instance
      assert Resources.get_simple_ship_instance(simple_ship_instance.id) == simple_ship_instance
    end

    test "create_simple_ship_instance/1 with valid data creates a simple_ship_instance" do
      assert {:ok, %SimpleShipInstance{} = simple_ship_instance} =
               Resources.create_simple_ship_instance(valid_attrs())

      assert simple_ship_instance.quantity == 123
    end

    test "create_simple_ship_instance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Resources.create_simple_ship_instance(invalid_attrs())
    end

    test "update_simple_ship_instance/2 with valid data updates the simple_ship_instance" do
      simple_ship_instance = ResourcesFixtures.simple_ship_instance_fixture()

      assert {:ok, %SimpleShipInstance{} = simple_ship_instance} =
               Resources.update_simple_ship_instance(simple_ship_instance, update_attrs())

      assert simple_ship_instance.quantity == 456
    end

    test "update_simple_ship_instance/2 with invalid data returns error changeset" do
      simple_ship_instance = ResourcesFixtures.simple_ship_instance_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Resources.update_simple_ship_instance(simple_ship_instance, invalid_attrs())

      assert simple_ship_instance == Resources.get_simple_ship_instance!(simple_ship_instance.id)
    end

    test "delete_simple_ship_instance/1 deletes the simple_ship_instance" do
      simple_ship_instance = ResourcesFixtures.simple_ship_instance_fixture()

      assert {:ok, %SimpleShipInstance{}} =
               Resources.delete_simple_ship_instance(simple_ship_instance)

      assert_raise Ecto.NoResultsError, fn ->
        Resources.get_simple_ship_instance!(simple_ship_instance.id)
      end

      assert Resources.get_simple_ship_instance(simple_ship_instance.id) == nil
    end

    test "change_simple_ship_instance/1 returns a simple_ship_instance changeset" do
      simple_ship_instance = ResourcesFixtures.simple_ship_instance_fixture()
      assert %Ecto.Changeset{} = Resources.change_simple_ship_instance(simple_ship_instance)
    end
  end
end
