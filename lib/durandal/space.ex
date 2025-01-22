defmodule Durandal.Space do
  @moduledoc """

  """

  # Systems
  alias Durandal.Space.{System, SystemLib, SystemQueries}

  @doc false
  @spec system_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate system_query(args), to: SystemQueries

  @doc section: :system
  @spec list_systems(Durandal.query_args()) :: [System.t()]
  defdelegate list_systems(args), to: SystemLib

  @doc section: :system
  @spec get_system!(System.id(), Durandal.query_args()) :: System.t()
  defdelegate get_system!(system_id, query_args \\ []), to: SystemLib

  @doc section: :system
  @spec get_system(System.id(), Durandal.query_args()) :: System.t() | nil
  defdelegate get_system(system_id, query_args \\ []), to: SystemLib

  @doc section: :system
  @spec create_system(map) :: {:ok, System.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_system(attrs), to: SystemLib

  @doc section: :system
  @spec update_system(System, map) :: {:ok, System.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_system(system, attrs), to: SystemLib

  @doc section: :system
  @spec delete_system(System.t()) :: {:ok, System.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_system(system), to: SystemLib

  @doc section: :system
  @spec change_system(System.t(), map) :: Ecto.Changeset.t()
  defdelegate change_system(system, attrs \\ %{}), to: SystemLib

  # Colonys
  alias Durandal.Space.{Colony, ColonyLib, ColonyQueries}

  @doc false
  @spec colony_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate colony_query(args), to: ColonyQueries

  @doc section: :colony
  @spec list_colonies(Durandal.query_args()) :: [Colony.t()]
  defdelegate list_colonies(args), to: ColonyLib

  @doc section: :colony
  @spec get_colony!(Colony.id(), Durandal.query_args()) :: Colony.t()
  defdelegate get_colony!(colony_id, query_args \\ []), to: ColonyLib

  @doc section: :colony
  @spec get_colony(Colony.id(), Durandal.query_args()) :: Colony.t() | nil
  defdelegate get_colony(colony_id, query_args \\ []), to: ColonyLib

  @doc section: :colony
  @spec create_colony(map) :: {:ok, Colony.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_colony(attrs), to: ColonyLib

  @doc section: :colony
  @spec update_colony(Colony, map) :: {:ok, Colony.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_colony(colony, attrs), to: ColonyLib

  @doc section: :colony
  @spec delete_colony(Colony.t()) :: {:ok, Colony.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_colony(colony), to: ColonyLib

  @doc section: :colony
  @spec change_colony(Colony.t(), map) :: Ecto.Changeset.t()
  defdelegate change_colony(colony, attrs \\ %{}), to: ColonyLib

  # ColonyModules
  alias Durandal.Space.{ColonyModule, ColonyModuleLib, ColonyModuleQueries}

  @doc false
  @spec colony_module_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate colony_module_query(args), to: ColonyModuleQueries

  @doc section: :colony_module
  @spec list_colony_modules(Durandal.query_args()) :: [ColonyModule.t()]
  defdelegate list_colony_modules(args), to: ColonyModuleLib

  @doc section: :colony_module
  @spec get_colony_module!(ColonyModule.id(), Durandal.query_args()) :: ColonyModule.t()
  defdelegate get_colony_module!(colony_module_id, query_args \\ []), to: ColonyModuleLib

  @doc section: :colony_module
  @spec get_colony_module(ColonyModule.id(), Durandal.query_args()) :: ColonyModule.t() | nil
  defdelegate get_colony_module(colony_module_id, query_args \\ []), to: ColonyModuleLib

  @doc section: :colony_module
  @spec create_colony_module(map) :: {:ok, ColonyModule.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_colony_module(attrs), to: ColonyModuleLib

  @doc section: :colony_module
  @spec update_colony_module(ColonyModule, map) ::
          {:ok, ColonyModule.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_colony_module(colony_module, attrs), to: ColonyModuleLib

  @doc section: :colony_module
  @spec delete_colony_module(ColonyModule.t()) ::
          {:ok, ColonyModule.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_colony_module(colony_module), to: ColonyModuleLib

  @doc section: :colony_module
  @spec change_colony_module(ColonyModule.t(), map) :: Ecto.Changeset.t()
  defdelegate change_colony_module(colony_module, attrs \\ %{}), to: ColonyModuleLib

  # Stations
  alias Durandal.Space.{Station, StationLib, StationQueries}

  @doc false
  @spec station_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate station_query(args), to: StationQueries

  @doc section: :station
  @spec list_stations(Durandal.query_args()) :: [Station.t()]
  defdelegate list_stations(args), to: StationLib

  @doc section: :station
  @spec get_station!(Station.id(), Durandal.query_args()) :: Station.t()
  defdelegate get_station!(station_id, query_args \\ []), to: StationLib

  @doc section: :station
  @spec get_station(Station.id(), Durandal.query_args()) :: Station.t() | nil
  defdelegate get_station(station_id, query_args \\ []), to: StationLib

  @doc section: :station
  @spec create_station(map) :: {:ok, Station.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_station(attrs), to: StationLib

  @doc section: :station
  @spec update_station(Station, map) :: {:ok, Station.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_station(station, attrs), to: StationLib

  @doc section: :station
  @spec delete_station(Station.t()) :: {:ok, Station.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_station(station), to: StationLib

  @doc section: :station
  @spec change_station(Station.t(), map) :: Ecto.Changeset.t()
  defdelegate change_station(station, attrs \\ %{}), to: StationLib

  # StationModules
  alias Durandal.Space.{StationModule, StationModuleLib, StationModuleQueries}

  @doc false
  @spec station_module_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate station_module_query(args), to: StationModuleQueries

  @doc section: :station_module
  @spec list_station_modules(Durandal.query_args()) :: [StationModule.t()]
  defdelegate list_station_modules(args), to: StationModuleLib

  @doc section: :station_module
  @spec get_station_module!(StationModule.id(), Durandal.query_args()) :: StationModule.t()
  defdelegate get_station_module!(station_module_id, query_args \\ []), to: StationModuleLib

  @doc section: :station_module
  @spec get_station_module(StationModule.id(), Durandal.query_args()) :: StationModule.t() | nil
  defdelegate get_station_module(station_module_id, query_args \\ []), to: StationModuleLib

  @doc section: :station_module
  @spec create_station_module(map) :: {:ok, StationModule.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_station_module(attrs), to: StationModuleLib

  @doc section: :station_module
  @spec update_station_module(StationModule, map) ::
          {:ok, StationModule.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_station_module(station_module, attrs), to: StationModuleLib

  @doc section: :station_module
  @spec delete_station_module(StationModule.t()) ::
          {:ok, StationModule.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_station_module(station_module), to: StationModuleLib

  @doc section: :station_module
  @spec change_station_module(StationModule.t(), map) :: Ecto.Changeset.t()
  defdelegate change_station_module(station_module, attrs \\ %{}), to: StationModuleLib

  # Ships
  alias Durandal.Space.{Ship, ShipLib, ShipQueries}

  @doc false
  @spec ship_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate ship_query(args), to: ShipQueries

  @doc section: :ship
  @spec list_ships(Durandal.query_args()) :: [Ship.t()]
  defdelegate list_ships(args), to: ShipLib

  @doc section: :ship
  @spec get_ship!(Ship.id(), Durandal.query_args()) :: Ship.t()
  defdelegate get_ship!(ship_id, query_args \\ []), to: ShipLib

  @doc section: :ship
  @spec get_ship(Ship.id(), Durandal.query_args()) :: Ship.t() | nil
  defdelegate get_ship(ship_id, query_args \\ []), to: ShipLib

  @doc section: :ship
  @spec create_ship(map) :: {:ok, Ship.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_ship(attrs), to: ShipLib

  @doc section: :ship
  @spec update_ship(Ship, map) :: {:ok, Ship.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_ship(ship, attrs), to: ShipLib

  @doc section: :ship
  @spec delete_ship(Ship.t()) :: {:ok, Ship.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_ship(ship), to: ShipLib

  @doc section: :ship
  @spec change_ship(Ship.t(), map) :: Ecto.Changeset.t()
  defdelegate change_ship(ship, attrs \\ %{}), to: ShipLib
end
