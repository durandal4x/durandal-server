defmodule Durandal.SystemObjectLibTest do
  @moduledoc false
  alias Durandal.Space.SystemObject
  alias Durandal.Space
  use Durandal.DataCase, async: true

  alias Durandal.SpaceFixtures
  import Durandal.GameFixtures, only: [universe_fixture: 0]
  import Durandal.TypesFixtures, only: [system_object_type_fixture: 0]

  defp valid_attrs do
    %{
      name: "some name",
      type_id: system_object_type_fixture().id,
      system_id: SpaceFixtures.system_fixture().id,
      universe_id: universe_fixture().id,
      position: [123, 456],
      velocity: [123, 456],
      orbiting_id: nil,
      orbit_distance: 123,
      orbit_clockwise: true,
      orbit_period: 123
    }
  end

  defp update_attrs do
    %{
      name: "some updated name",
      type_id: system_object_type_fixture().id,
      system_id: SpaceFixtures.system_fixture().id,
      universe_id: universe_fixture().id,
      position: [123, 456, 789],
      velocity: [123, 456, 789],
      orbiting_id: nil,
      orbit_distance: 456,
      orbit_clockwise: false,
      orbit_period: 456
    }
  end

  defp invalid_attrs do
    %{
      name: nil,
      type_id: nil,
      system_id: nil,
      universe_id: nil,
      position: nil,
      velocity: nil,
      orbiting_id: nil,
      orbit_distance: nil,
      orbit_clockwise: nil,
      orbit_period: nil
    }
  end

  describe "system_object" do
    alias Durandal.Space.SystemObject

    test "system_object_query/0 returns a query" do
      q = Space.system_object_query([])
      assert %Ecto.Query{} = q
    end

    test "list_system_object/0 returns system_object" do
      # No system_object yet
      assert Space.list_system_objects([]) == []

      # Add a system_object
      SpaceFixtures.system_object_fixture()
      assert Space.list_system_objects([]) != []
    end

    test "get_system_object!/1 and get_system_object/1 returns the system_object with given id" do
      system_object = SpaceFixtures.system_object_fixture()
      assert Space.get_system_object!(system_object.id) == system_object
      assert Space.get_system_object(system_object.id) == system_object
    end

    test "create_system_object/1 with valid data creates a system_object" do
      assert {:ok, %SystemObject{} = system_object} =
               Space.create_system_object(valid_attrs())

      assert system_object.name == "some name"
      assert system_object.position == [123, 456]
      assert system_object.velocity == [123, 456]
      assert system_object.orbit_distance == 123
      assert system_object.orbit_period == 123
    end

    test "create_system_object/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Space.create_system_object(invalid_attrs())
    end

    test "update_system_object/2 with valid data updates the system_object" do
      system_object = SpaceFixtures.system_object_fixture()

      assert {:ok, %SystemObject{} = system_object} =
               Space.update_system_object(system_object, update_attrs())

      assert system_object.name == "some updated name"
      assert system_object.position == [123, 456, 789]
      assert system_object.velocity == [123, 456, 789]
      assert system_object.orbit_distance == 456
      assert system_object.orbit_period == 456
    end

    test "update_system_object/2 with invalid data returns error changeset" do
      system_object = SpaceFixtures.system_object_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Space.update_system_object(system_object, invalid_attrs())

      assert system_object == Space.get_system_object!(system_object.id)
    end

    test "delete_system_object/1 deletes the system_object" do
      system_object = SpaceFixtures.system_object_fixture()
      assert {:ok, %SystemObject{}} = Space.delete_system_object(system_object)

      assert_raise Ecto.NoResultsError, fn ->
        Space.get_system_object!(system_object.id)
      end

      assert Space.get_system_object(system_object.id) == nil
    end

    test "change_system_object/1 returns a system_object changeset" do
      system_object = SpaceFixtures.system_object_fixture()
      assert %Ecto.Changeset{} = Space.change_system_object(system_object)
    end
  end
end
