defmodule Durandal.TypesFixtures do
  @moduledoc false

  alias Durandal.Types.SystemObjectType

  @spec system_object_type_fixture(map) :: SystemObjectType.t()
  def system_object_type_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    SystemObjectType.changeset(
      %SystemObjectType{},
      %{
        name: data["name"] || "system_object_type_name_#{r}"
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Types.ColonyModuleType

  @spec colony_module_type_fixture(map) :: ColonyModuleType.t()
  def colony_module_type_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    ColonyModuleType.changeset(
      %ColonyModuleType{},
      %{
        name: data["name"] || "colony_module_types_name_#{r}"
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Types.StationModuleType

  @spec station_module_type_fixture(map) :: StationModuleType.t()
  def station_module_type_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    StationModuleType.changeset(
      %StationModuleType{},
      %{
        name: data["name"] || "station_module_type_name_#{r}"
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Types.ShipType

  @spec ship_type_fixture(map) :: ShipType.t()
  def ship_type_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    ShipType.changeset(
      %ShipType{},
      %{
        name: data["name"] || "ship_type_name_#{r}"
      }
    )
    |> Durandal.Repo.insert!()
  end
end
