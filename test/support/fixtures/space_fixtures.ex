defmodule Durandal.SpaceFixtures do
  @moduledoc false

  alias Durandal.Space.System
  import Durandal.GameFixtures, only: [universe_fixture: 0]
  import Durandal.PlayerFixtures, only: [team_fixture: 0]

  import Durandal.TypesFixtures,
    only: [system_object_type_fixture: 1, station_module_type_fixture: 1, ship_type_fixture: 1]

  @spec system_fixture(map) :: System.t()
  def system_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    System.changeset(
      %System{},
      %{
        name: data["name"] || "system_name_#{r}",
        universe_id: data["universe_id"] || universe_fixture().id
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Space.SystemObject

  @spec system_object_fixture(map) :: SystemObject.t()
  def system_object_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)
    team = Durandal.Player.get_team(data["team_id"]) || team_fixture()

    SystemObject.changeset(
      %SystemObject{},
      %{
        name: data["name"] || "system_object_name_#{r}",
        system_id: data["system_id"] || system_fixture(%{"universe_id" => team.universe_id}).id,
        type_id:
          data["type_id"] || system_object_type_fixture(%{"universe_id" => team.universe_id}).id,
        universe_id: team.universe_id,
        position: data["position"] || [r, r + 1, r + 2],
        velocity: data["velocity"] || [r, r + 1, r + 2],
        orbiting_id: data["orbiting_id"] || nil,
        orbit_clockwise: data["orbit_clockwise"] || true,
        orbit_period: data["orbit_period"] || r
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Space.Station

  @spec station_fixture(map) :: Station.t()
  def station_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)
    team = Durandal.Player.get_team(data["team_id"]) || team_fixture()

    Station.changeset(
      %Station{},
      %{
        name: data["name"] || "station_name_#{r}",
        team_id: team.id,
        system_id: data["system_id"] || system_fixture(%{"universe_id" => team.universe_id}).id,
        universe_id: team.universe_id,
        position: data["position"] || [r, r + 1, r + 2],
        velocity: data["velocity"] || [r, r + 1, r + 2],
        orbiting_id: data["orbiting_id"] || nil,
        orbit_clockwise: data["orbit_clockwise"] || true,
        orbit_period: data["orbit_period"] || r
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Space.StationModule

  @spec station_module_fixture(map) :: StationModule.t()
  def station_module_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)
    team = Durandal.Player.get_team(data["team_id"]) || team_fixture()

    StationModule.changeset(
      %StationModule{},
      %{
        station_id:
          data["station_id"] || station_fixture(%{"universe_id" => team.universe_id}).id,
        type_id:
          data["type_id"] || station_module_type_fixture(%{"universe_id" => team.universe_id}).id,
        universe_id: team.universe_id,
        build_progress: data["build_progress"] || r,
        health: data["health"] || r
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Space.Ship

  @spec ship_fixture(map) :: Ship.t()
  def ship_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)
    team = Durandal.Player.get_team(data["team_id"]) || team_fixture()

    Ship.changeset(
      %Ship{},
      %{
        name: data["name"] || "ship_name_#{r}",
        team_id: team.id,
        type_id: data["type_id"] || ship_type_fixture(%{"universe_id" => team.universe_id}).id,
        system_id: data["system_id"] || system_fixture(%{"universe_id" => team.universe_id}).id,
        universe_id: team.universe_id,
        position: data["position"] || [r, r + 1, r + 2],
        velocity: data["velocity"] || [r, r + 1, r + 2],
        orbiting_id: data["orbiting_id"] || nil,
        orbit_clockwise: data["orbit_clockwise"] || true,
        orbit_period: data["orbit_period"] || r,
        build_progress: data["build_progress"] || r,
        health: data["health"] || r,
        docked_with_id: data["docked_with_id"]
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Space.ShipTransfer

  @spec ship_transfer_fixture(map) :: ShipTransfer.t()
  def ship_transfer_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    ship =
      Durandal.Space.get_ship(data["ship_id"]) || ship_fixture()

    to_params =
      if data["to_station_id"] do
        %{
          to_station_id: data["to_station_id"],
          to_system_object_id: nil
        }
      else
        %{
          to_station_id: nil,
          to_system_object_id: data["to_system_object_id"] || system_object_fixture().id
        }
      end

    ShipTransfer.changeset(
      %ShipTransfer{},
      Map.merge(to_params, %{
        universe_id: ship.universe_id,
        ship_id: ship.id,
        origin: data["origin"] || [r, r, r],
        distance: data["distance"] || r,
        progress: data["progress"] || 50,
        status: data["status"] || "in progress",
        started_tick: data["started_tick"] || r,
        completed_tick: data["completed_tick"]
      })
    )
    |> Durandal.Repo.insert!()
  end
end
