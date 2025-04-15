defmodule Durandal.Space do
  @moduledoc """

  """

  # Systems
  alias Durandal.Space.{System, SystemLib, SystemQueries}

  @doc false
  @spec system_topic(Durandal.system_id()) :: String.t()
  defdelegate system_topic(system_id), to: SystemLib, as: :topic

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

  # Stations
  alias Durandal.Space.{Station, StationLib, StationQueries}

  @doc false
  @spec station_topic(Durandal.station_id()) :: String.t()
  defdelegate station_topic(station_id), to: StationLib, as: :topic

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
  @spec get_extended_station(Station.id()) :: Station.t() | nil
  defdelegate get_extended_station(station_id), to: StationLib

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
  @spec station_module_topic(Durandal.station_module_id()) :: String.t()
  defdelegate station_module_topic(station_module_id), to: StationModuleLib, as: :topic

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
  @spec ship_topic(Durandal.ship_id()) :: String.t()
  defdelegate ship_topic(ship_id), to: ShipLib, as: :topic

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
  @spec get_extended_ship(Ship.id()) :: Ship.t() | nil
  defdelegate get_extended_ship(ship_id), to: ShipLib

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

  # SystemObjects
  alias Durandal.Space.{SystemObject, SystemObjectLib, SystemObjectQueries}

  @doc false
  @spec system_object_topic(Durandal.system_object_id()) :: String.t()
  defdelegate system_object_topic(system_object_id), to: SystemObjectLib, as: :topic

  @doc false
  @spec system_object_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate system_object_query(args), to: SystemObjectQueries

  @doc section: :system_object
  @spec list_system_objects(Durandal.query_args()) :: [SystemObject.t()]
  defdelegate list_system_objects(args), to: SystemObjectLib

  @doc section: :system_object
  @spec get_system_object!(SystemObject.id(), Durandal.query_args()) :: SystemObject.t()
  defdelegate get_system_object!(system_object_id, query_args \\ []), to: SystemObjectLib

  @doc section: :system_object
  @spec get_system_object(SystemObject.id(), Durandal.query_args()) :: SystemObject.t() | nil
  defdelegate get_system_object(system_object_id, query_args \\ []), to: SystemObjectLib

  @doc section: :system_object
  @spec create_system_object(map) :: {:ok, SystemObject.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_system_object(attrs), to: SystemObjectLib

  @doc section: :system_object
  @spec update_system_object(SystemObject, map) ::
          {:ok, SystemObject.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_system_object(system_object, attrs), to: SystemObjectLib

  @doc section: :system_object
  @spec delete_system_object(SystemObject.t()) ::
          {:ok, SystemObject.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_system_object(system_object), to: SystemObjectLib

  @doc section: :system_object
  @spec change_system_object(SystemObject.t(), map) :: Ecto.Changeset.t()
  defdelegate change_system_object(system_object, attrs \\ %{}), to: SystemObjectLib

  # ShipTransfers
  alias Durandal.Space.{ShipTransfer, ShipTransferLib, ShipTransferQueries}

  @doc false
  @spec ship_transfer_topic(Durandal.ship_transfer_id()) :: String.t()
  defdelegate ship_transfer_topic(ship_transfer_id), to: ShipTransferLib, as: :topic

  @doc false
  @spec ship_transfer_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate ship_transfer_query(args), to: ShipTransferQueries

  @doc section: :ship_transfer
  @spec list_ship_transfers(Durandal.query_args()) :: [ShipTransfer.t()]
  defdelegate list_ship_transfers(args), to: ShipTransferLib

  @doc section: :ship_transfer
  @spec get_ship_transfer!(ShipTransfer.id(), Durandal.query_args()) :: ShipTransfer.t()
  defdelegate get_ship_transfer!(ship_transfer_id, query_args \\ []), to: ShipTransferLib

  @doc section: :ship_transfer
  @spec get_ship_transfer(ShipTransfer.id(), Durandal.query_args()) :: ShipTransfer.t() | nil
  defdelegate get_ship_transfer(ship_transfer_id, query_args \\ []), to: ShipTransferLib

  @doc section: :ship_transfer
  @spec create_ship_transfer(map) :: {:ok, ShipTransfer.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_ship_transfer(attrs), to: ShipTransferLib

  @doc section: :ship_transfer
  @spec update_ship_transfer(ShipTransfer, map) ::
          {:ok, ShipTransfer.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_ship_transfer(ship_transfer, attrs), to: ShipTransferLib

  @doc section: :ship_transfer
  @spec delete_ship_transfer(ShipTransfer.t()) ::
          {:ok, ShipTransfer.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_ship_transfer(ship_transfer), to: ShipTransferLib

  @doc section: :ship_transfer
  @spec change_ship_transfer(ShipTransfer.t(), map) :: Ecto.Changeset.t()
  defdelegate change_ship_transfer(ship_transfer, attrs \\ %{}), to: ShipTransferLib

  # StationTransfers
  alias Durandal.Space.{StationTransfer, StationTransferLib, StationTransferQueries}

  @doc false
  @spec station_transfer_topic(Durandal.station_transfer_id()) :: String.t()
  defdelegate station_transfer_topic(station_transfer_id), to: StationTransferLib, as: :topic

  @doc false
  @spec station_transfer_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate station_transfer_query(args), to: StationTransferQueries

  @doc section: :station_transfer
  @spec list_station_transfers(Durandal.query_args()) :: [StationTransfer.t()]
  defdelegate list_station_transfers(args), to: StationTransferLib

  @doc section: :station_transfer
  @spec get_station_transfer!(StationTransfer.id(), Durandal.query_args()) :: StationTransfer.t()
  defdelegate get_station_transfer!(station_transfer_id, query_args \\ []), to: StationTransferLib

  @doc section: :station_transfer
  @spec get_station_transfer(StationTransfer.id(), Durandal.query_args()) ::
          StationTransfer.t() | nil
  defdelegate get_station_transfer(station_transfer_id, query_args \\ []), to: StationTransferLib

  @doc section: :station_transfer
  @spec create_station_transfer(map) :: {:ok, StationTransfer.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_station_transfer(attrs), to: StationTransferLib

  @doc section: :station_transfer
  @spec update_station_transfer(StationTransfer, map) ::
          {:ok, StationTransfer.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_station_transfer(station_transfer, attrs), to: StationTransferLib

  @doc section: :station_transfer
  @spec delete_station_transfer(StationTransfer.t()) ::
          {:ok, StationTransfer.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_station_transfer(station_transfer), to: StationTransferLib

  @doc section: :station_transfer
  @spec change_station_transfer(StationTransfer.t(), map) :: Ecto.Changeset.t()
  defdelegate change_station_transfer(station_transfer, attrs \\ %{}), to: StationTransferLib

  alias Durandal.Space.TransferLib

  @doc section: :transfer
  @spec calculate_distance(Durandal.positional_entity(), Durandal.positional_entity()) ::
          non_neg_integer()
  defdelegate calculate_distance(from_entity, to_entity), to: TransferLib

  @doc section: :transfer
  @spec calculate_midpoint(Maths.vector(), Maths.vector(), number()) :: Maths.vector()
  defdelegate calculate_midpoint(origin, destination, progress_percentage), to: TransferLib
end
