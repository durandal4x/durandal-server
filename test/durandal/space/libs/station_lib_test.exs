defmodule Durandal.StationLibTest do
  @moduledoc false
  alias Durandal.Space.Station
  alias Durandal.Space
  use Durandal.DataCase, async: true

  alias Durandal.SpaceFixtures
  import Durandal.GameFixtures, only: [universe_fixture: 0]
  import Durandal.PlayerFixtures, only: [team_fixture: 0]

  defp valid_attrs do
    %{
      name: "some name",
      team_id: team_fixture().id,
      universe_id: universe_fixture().id,
      system_id: SpaceFixtures.system_fixture().id,
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
      team_id: team_fixture().id,
      universe_id: universe_fixture().id,
      system_id: SpaceFixtures.system_fixture().id,
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
      team_id: nil,
      universe_id: nil,
      system_id: nil,
      position: nil,
      velocity: nil,
      orbiting_id: nil,
      orbit_distance: nil,
      orbit_clockwise: nil,
      orbit_period: nil
    }
  end

  describe "station" do
    alias Durandal.Space.Station

    test "station_query/0 returns a query" do
      q = Space.station_query([])
      assert %Ecto.Query{} = q
    end

    test "list_station/0 returns station" do
      # No station yet
      assert Space.list_stations([]) == []

      # Add a station
      SpaceFixtures.station_fixture()
      assert Space.list_stations([]) != []
    end

    test "get_station!/1 and get_station/1 returns the station with given id" do
      station = SpaceFixtures.station_fixture()
      assert Space.get_station!(station.id) == station
      assert Space.get_station(station.id) == station
    end

    test "create_station/1 with valid data creates a station" do
      assert {:ok, %Station{} = station} =
               Space.create_station(valid_attrs())

      assert station.name == "some name"
      assert station.position == [123, 456]
      assert station.velocity == [123, 456]
      assert station.orbit_distance == 123
      assert station.orbit_period == 123
    end

    test "create_station/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Space.create_station(invalid_attrs())
    end

    test "update_station/2 with valid data updates the station" do
      station = SpaceFixtures.station_fixture()

      assert {:ok, %Station{} = station} =
               Space.update_station(station, update_attrs())

      assert station.name == "some updated name"
      assert station.position == [123, 456, 789]
      assert station.velocity == [123, 456, 789]
      assert station.orbit_distance == 456
      assert station.orbit_period == 456
    end

    test "update_station/2 with invalid data returns error changeset" do
      station = SpaceFixtures.station_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Space.update_station(station, invalid_attrs())

      assert station == Space.get_station!(station.id)
    end

    test "delete_station/1 deletes the station" do
      station = SpaceFixtures.station_fixture()
      assert {:ok, %Station{}} = Space.delete_station(station)

      assert_raise Ecto.NoResultsError, fn ->
        Space.get_station!(station.id)
      end

      assert Space.get_station(station.id) == nil
    end

    test "change_station/1 returns a station changeset" do
      station = SpaceFixtures.station_fixture()
      assert %Ecto.Changeset{} = Space.change_station(station)
    end
  end
end
