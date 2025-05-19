defmodule Durandal.ResourcesFixtures do
  @moduledoc false

  import Durandal.GameFixtures, only: [universe_fixture: 0]
  import Durandal.PlayerFixtures, only: [team_fixture: 0]
  import Durandal.SpaceFixtures, only: [station_module_fixture: 0, ship_fixture: 0]
  alias Durandal.Resources.SimpleType

  @spec simple_type_fixture(map) :: SimpleType.t()
  def simple_type_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    SimpleType.changeset(
      %SimpleType{},
      %{
        name: data["name"] || "simple_type_name_#{r}",
        mass: data["mass"] || r,
        volume: data["volume"] || r,
        tags: data["tags"] || ["simple_type_tags_#{r}_1", "simple_type_tags_#{r}_2"],
        universe_id: data["universe_id"] || universe_fixture().id
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Resources.SimpleStationModuleInstance

  @spec simple_station_module_instance_fixture(map) :: SimpleStationModuleInstance.t()
  def simple_station_module_instance_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    SimpleStationModuleInstance.changeset(
      %SimpleStationModuleInstance{},
      %{
        type_id: data["type_id"] || simple_type_fixture().id,
        quantity: data["quantity"] || r,
        universe_id: data["universe_id"] || universe_fixture().id,
        station_module_id: data["station_module_id"] || station_module_fixture().id,
        team_id: data["team_id"] || team_fixture().id
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Resources.SimpleShipInstance

  @spec simple_ship_instance_fixture(map) :: SimpleShipInstance.t()
  def simple_ship_instance_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    SimpleShipInstance.changeset(
      %SimpleShipInstance{},
      %{
        type_id: data["type_id"] || simple_type_fixture().id,
        quantity: data["quantity"] || r,
        universe_id: data["universe_id"] || universe_fixture().id,
        ship_id: data["ship_id"] || ship_fixture().id,
        team_id: data["team_id"] || team_fixture().id
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Resources.CompositeType

  @spec composite_type_fixture(map) :: CompositeType.t()
  def composite_type_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    CompositeType.changeset(
      %CompositeType{},
      %{
        name: data["name"] || "composite_type_name_#{r}",
        contents:
          data["contents"] ||
            ["65e90589-5dbe-4b4c-a3e4-5f2fd889bead", "006dd7a9-a4b9-40a0-a80f-5f197620d2cb"],
        universe_id: data["universe_id"] || universe_fixture().id
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Resources.CompositeStationModuleInstance

  @spec composite_station_module_instance_fixture(map) :: CompositeStationModuleInstance.t()
  def composite_station_module_instance_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    CompositeStationModuleInstance.changeset(
      %CompositeStationModuleInstance{},
      %{
        type_id: data["type_id"] || composite_type_fixture().id,
        ratios: data["ratios"] || [r, r + 1],
        quantity: data["quantity"] || r,
        combined_mass: data["combined_mass"] || r,
        combined_volume: data["combined_volume"] || r,
        universe_id: data["universe_id"] || universe_fixture().id,
        station_module_id: data["station_module_id"] || station_module_fixture().id,
        team_id: data["team_id"] || team_fixture().id
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Resources.CompositeShipInstance

  @spec composite_ship_instance_fixture(map) :: CompositeShipInstance.t()
  def composite_ship_instance_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    CompositeShipInstance.changeset(
      %CompositeShipInstance{},
      %{
        type_id: data["type_id"] || composite_type_fixture().id,
        ratios: data["ratios"] || [r, r + 1],
        quantity: data["quantity"] || r,
        combined_mass: data["combined_mass"] || r,
        combined_volume: data["combined_volume"] || r,
        universe_id: data["universe_id"] || universe_fixture().id,
        ship_id: data["ship_id"] || ship_fixture().id,
        team_id: data["team_id"] || team_fixture().id
      }
    )
    |> Durandal.Repo.insert!()
  end
end
