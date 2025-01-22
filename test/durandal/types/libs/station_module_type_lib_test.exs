defmodule Durandal.StationModuleTypeLibTest do
  @moduledoc false
  alias Durandal.Types.StationModuleType
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

  describe "station_module_type" do
    alias Durandal.Types.StationModuleType

    test "station_module_type_query/0 returns a query" do
      q = Types.station_module_type_query([])
      assert %Ecto.Query{} = q
    end

    test "list_station_module_type/0 returns station_module_type" do
      # No station_module_type yet
      assert Types.list_station_module_types([]) == []

      # Add a station_module_type
      TypesFixtures.station_module_type_fixture()
      assert Types.list_station_module_types([]) != []
    end

    test "get_station_module_type!/1 and get_station_module_type/1 returns the station_module_type with given id" do
      station_module_type = TypesFixtures.station_module_type_fixture()
      assert Types.get_station_module_type!(station_module_type.id) == station_module_type
      assert Types.get_station_module_type(station_module_type.id) == station_module_type
    end

    test "create_station_module_type/1 with valid data creates a station_module_type" do
      assert {:ok, %StationModuleType{} = station_module_type} =
               Types.create_station_module_type(valid_attrs())

      assert station_module_type.name == "some name"
    end

    test "create_station_module_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Types.create_station_module_type(invalid_attrs())
    end

    test "update_station_module_type/2 with valid data updates the station_module_type" do
      station_module_type = TypesFixtures.station_module_type_fixture()

      assert {:ok, %StationModuleType{} = station_module_type} =
               Types.update_station_module_type(station_module_type, update_attrs())

      assert station_module_type.name == "some updated name"
    end

    test "update_station_module_type/2 with invalid data returns error changeset" do
      station_module_type = TypesFixtures.station_module_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Types.update_station_module_type(station_module_type, invalid_attrs())

      assert station_module_type == Types.get_station_module_type!(station_module_type.id)
    end

    test "delete_station_module_type/1 deletes the station_module_type" do
      station_module_type = TypesFixtures.station_module_type_fixture()
      assert {:ok, %StationModuleType{}} = Types.delete_station_module_type(station_module_type)

      assert_raise Ecto.NoResultsError, fn ->
        Types.get_station_module_type!(station_module_type.id)
      end

      assert Types.get_station_module_type(station_module_type.id) == nil
    end

    test "change_station_module_type/1 returns a station_module_type changeset" do
      station_module_type = TypesFixtures.station_module_type_fixture()
      assert %Ecto.Changeset{} = Types.change_station_module_type(station_module_type)
    end
  end
end
