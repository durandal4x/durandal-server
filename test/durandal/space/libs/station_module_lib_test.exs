defmodule Durandal.StationModuleLibTest do
  @moduledoc false
  alias Durandal.Space.StationModule
  alias Durandal.Space
  use Durandal.DataCase, async: true

  import Durandal.SpaceFixtures, only: [station_fixture: 0, station_module_fixture: 0]
  import Durandal.TypesFixtures, only: [station_module_type_fixture: 0]

  defp valid_attrs do
    %{
      station_id: station_fixture().id,
      type_id: station_module_type_fixture().id
    }
  end

  defp update_attrs do
    %{
      station_id: station_fixture().id,
      type_id: station_module_type_fixture().id
    }
  end

  defp invalid_attrs do
    %{
      station_id: nil,
      type_id: nil
    }
  end

  describe "station_module" do
    alias Durandal.Space.StationModule

    test "station_module_query/0 returns a query" do
      q = Space.station_module_query([])
      assert %Ecto.Query{} = q
    end

    test "list_station_module/0 returns station_module" do
      # No station_module yet
      assert Space.list_station_modules([]) == []

      # Add a station_module
      station_module_fixture()
      assert Space.list_station_modules([]) != []
    end

    test "get_station_module!/1 and get_station_module/1 returns the station_module with given id" do
      station_module = station_module_fixture()
      assert Space.get_station_module!(station_module.id) == station_module
      assert Space.get_station_module(station_module.id) == station_module
    end

    test "create_station_module/1 with valid data creates a station_module" do
      assert {:ok, %StationModule{} = _station_module} =
               Space.create_station_module(valid_attrs())
    end

    test "create_station_module/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Space.create_station_module(invalid_attrs())
    end

    test "update_station_module/2 with valid data updates the station_module" do
      station_module = station_module_fixture()

      assert {:ok, %StationModule{} = _station_module} =
               Space.update_station_module(station_module, update_attrs())
    end

    test "update_station_module/2 with invalid data returns error changeset" do
      station_module = station_module_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Space.update_station_module(station_module, invalid_attrs())

      assert station_module == Space.get_station_module!(station_module.id)
    end

    test "delete_station_module/1 deletes the station_module" do
      station_module = station_module_fixture()
      assert {:ok, %StationModule{}} = Space.delete_station_module(station_module)

      assert_raise Ecto.NoResultsError, fn ->
        Space.get_station_module!(station_module.id)
      end

      assert Space.get_station_module(station_module.id) == nil
    end

    test "change_station_module/1 returns a station_module changeset" do
      station_module = station_module_fixture()
      assert %Ecto.Changeset{} = Space.change_station_module(station_module)
    end
  end
end