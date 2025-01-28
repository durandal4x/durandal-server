defmodule Durandal.SpaceFixtures do
  @moduledoc false

  alias Durandal.Space.System
  import Durandal.GameFixtures, only: [universe_fixture: 0]
  import Durandal.PlayerFixtures, only: [team_fixture: 0]

  import Durandal.TypesFixtures,
    only: [colony_module_type_fixture: 0, station_module_type_fixture: 0, ship_type_fixture: 0]

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

  alias Durandal.Space.Colony

  @spec colony_fixture(map) :: Colony.t()
  def colony_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    Colony.changeset(
      %Colony{},
      %{
        name: data["name"] || "colony_name_#{r}",
        team_id: data["team_id"] || team_fixture().id,
        position: data["position"] || [r, r + 1]
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Space.ColonyModule

  @spec colony_module_fixture(map) :: ColonyModule.t()
  def colony_module_fixture(data \\ %{}) do
    ColonyModule.changeset(
      %ColonyModule{},
      %{
        colony_id: data["colony_id"] || colony_fixture().id,
        type_id: data["type_id"] || colony_module_type_fixture().id
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Space.Station

  @spec station_fixture(map) :: Station.t()
  def station_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    Station.changeset(
      %Station{},
      %{
        name: data["name"] || "station_name_#{r}",
        team_id: data["team_id"] || team_fixture().id,
        position: data["position"] || [r, r + 1]
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Space.StationModule

  @spec station_module_fixture(map) :: StationModule.t()
  def station_module_fixture(data \\ %{}) do
    StationModule.changeset(
      %StationModule{},
      %{
        station_id: data["station_id"] || station_fixture().id,
        type_id: data["type_id"] || station_module_type_fixture().id
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Space.Ship

  @spec ship_fixture(map) :: Ship.t()
  def ship_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    Ship.changeset(
      %Ship{},
      %{
        name: data["name"] || "ship_name_#{r}",
        team_id: data["team_id"] || team_fixture().id,
        type_id: data["type_id"] || ship_type_fixture().id,
        position: data["position"] || [r, r + 1]
      }
    )
    |> Durandal.Repo.insert!()
  end
end
