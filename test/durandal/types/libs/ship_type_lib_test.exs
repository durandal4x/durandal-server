defmodule Durandal.ShipTypeLibTest do
  @moduledoc false
  alias Durandal.Types.ShipType
  alias Durandal.Types
  use Durandal.DataCase, async: true

  import Durandal.GameFixtures, only: [universe_fixture: 0]
  alias Durandal.TypesFixtures

  defp valid_attrs do
    %{
      name: "some name",
      universe_id: universe_fixture().id
    }
  end

  defp update_attrs do
    %{
      name: "some updated name",
      universe_id: universe_fixture().id
    }
  end

  defp invalid_attrs do
    %{
      name: nil,
      universe_id: nil
    }
  end

  describe "ship_type" do
    alias Durandal.Types.ShipType

    test "ship_type_query/0 returns a query" do
      q = Types.ship_type_query([])
      assert %Ecto.Query{} = q
    end

    test "list_ship_type/0 returns ship_type" do
      # No ship_type yet
      assert Types.list_ship_types([]) == []

      # Add a ship_type
      TypesFixtures.ship_type_fixture()
      assert Types.list_ship_types([]) != []
    end

    test "get_ship_type!/1 and get_ship_type/1 returns the ship_type with given id" do
      ship_type = TypesFixtures.ship_type_fixture()
      assert Types.get_ship_type!(ship_type.id) == ship_type
      assert Types.get_ship_type(ship_type.id) == ship_type
    end

    test "create_ship_type/1 with valid data creates a ship_type" do
      assert {:ok, %ShipType{} = ship_type} =
               Types.create_ship_type(valid_attrs())

      assert ship_type.name == "some name"
    end

    test "create_ship_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Types.create_ship_type(invalid_attrs())
    end

    test "update_ship_type/2 with valid data updates the ship_type" do
      ship_type = TypesFixtures.ship_type_fixture()

      assert {:ok, %ShipType{} = ship_type} =
               Types.update_ship_type(ship_type, update_attrs())

      assert ship_type.name == "some updated name"
    end

    test "update_ship_type/2 with invalid data returns error changeset" do
      ship_type = TypesFixtures.ship_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Types.update_ship_type(ship_type, invalid_attrs())

      assert ship_type == Types.get_ship_type!(ship_type.id)
    end

    test "delete_ship_type/1 deletes the ship_type" do
      ship_type = TypesFixtures.ship_type_fixture()
      assert {:ok, %ShipType{}} = Types.delete_ship_type(ship_type)

      assert_raise Ecto.NoResultsError, fn ->
        Types.get_ship_type!(ship_type.id)
      end

      assert Types.get_ship_type(ship_type.id) == nil
    end

    test "change_ship_type/1 returns a ship_type changeset" do
      ship_type = TypesFixtures.ship_type_fixture()
      assert %Ecto.Changeset{} = Types.change_ship_type(ship_type)
    end
  end
end
