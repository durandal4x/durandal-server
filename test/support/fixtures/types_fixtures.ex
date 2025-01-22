defmodule Durandal.TypesFixtures do
  @moduledoc false

  alias Durandal.Types.SystemObjectType
  import Durandal.GameFixtures, only: [universe_fixture: 0]

  @spec system_object_type_fixture(map) :: SystemObjectType.t()
  def system_object_type_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    SystemObjectType.changeset(
      %SystemObjectType{},
      %{
        name: data["name"] || "system_object_type_name_#{r}",
        universe_id: data["universe_id"] || universe_fixture().id
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
        name: data["name"] || "station_module_type_name_#{r}",
        universe_id: data["universe_id"] || universe_fixture().id
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
        name: data["name"] || "ship_type_name_#{r}",
        universe_id: data["universe_id"] || universe_fixture().id
      }
    )
    |> Durandal.Repo.insert!()
  end
end
