defmodule Durandal.StationModuleLibTest do
  @moduledoc false
  alias Durandal.Space.StationModule
  alias Durandal.Space
  use Durandal.DataCase, async: true

  import Durandal.GameFixtures, only: [universe_fixture: 0]
  import Durandal.TypesFixtures, only: [station_module_type_fixture: 0]
  alias Durandal.SpaceFixtures

  defp valid_attrs do
    %{
      station_id: SpaceFixtures.station_fixture().id,
      type_id: station_module_type_fixture().id,
      universe_id: universe_fixture().id,
      build_progress: 123,
      health: 123
    }
  end

  defp update_attrs do
    %{
      station_id: SpaceFixtures.station_fixture().id,
      type_id: station_module_type_fixture().id,
      universe_id: universe_fixture().id,
      build_progress: 456,
      health: 456
    }
  end

  defp invalid_attrs do
    %{
      station_id: nil,
      universe_id: nil,
      type_id: nil,
      build_progress: nil,
      health: nil
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
      SpaceFixtures.station_module_fixture()
      assert Space.list_station_modules([]) != []
    end

    test "get_station_module!/1 and get_station_module/1 returns the station_module with given id" do
      station_module = SpaceFixtures.station_module_fixture()
      assert Space.get_station_module!(station_module.id) == station_module
      assert Space.get_station_module(station_module.id) == station_module
    end

    test "create_station_module/1 with valid data creates a station_module" do
      assert {:ok, %StationModule{} = station_module} =
               Space.create_station_module(valid_attrs())

      assert station_module.build_progress == 123
      assert station_module.health == 123
    end

    test "create_station_module/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Space.create_station_module(invalid_attrs())
    end

    test "update_station_module/2 with valid data updates the station_module" do
      station_module = SpaceFixtures.station_module_fixture()

      assert {:ok, %StationModule{} = station_module} =
               Space.update_station_module(station_module, update_attrs())

      assert station_module.build_progress == 456
      assert station_module.health == 456
    end

    test "update_station_module/2 with invalid data returns error changeset" do
      station_module = SpaceFixtures.station_module_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Space.update_station_module(station_module, invalid_attrs())

      assert station_module == Space.get_station_module!(station_module.id)
    end

    test "delete_station_module/1 deletes the station_module" do
      station_module = SpaceFixtures.station_module_fixture()
      assert {:ok, %StationModule{}} = Space.delete_station_module(station_module)

      assert_raise Ecto.NoResultsError, fn ->
        Space.get_station_module!(station_module.id)
      end

      assert Space.get_station_module(station_module.id) == nil
    end

    test "change_station_module/1 returns a station_module changeset" do
      station_module = SpaceFixtures.station_module_fixture()
      assert %Ecto.Changeset{} = Space.change_station_module(station_module)
    end
  end
end
