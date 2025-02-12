defmodule Durandal.Types do
  @moduledoc """

  """

  # SystemObjectTypes
  alias Durandal.Types.{SystemObjectType, SystemObjectTypeLib, SystemObjectTypeQueries}

  @doc false
  @spec system_object_type_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate system_object_type_query(args), to: SystemObjectTypeQueries

  @doc section: :system_object_type
  @spec list_object_type_types(Durandal.query_args()) :: [SystemObjectType.t()]
  defdelegate list_object_type_types(args), to: SystemObjectTypeLib

  @doc section: :system_object_type
  @spec get_object_type!(SystemObjectType.id(), Durandal.query_args()) :: SystemObjectType.t()
  defdelegate get_object_type!(system_object_type_id, query_args \\ []), to: SystemObjectTypeLib

  @doc section: :system_object_type
  @spec get_object_type(SystemObjectType.id(), Durandal.query_args()) ::
          SystemObjectType.t() | nil
  defdelegate get_object_type(system_object_type_id, query_args \\ []), to: SystemObjectTypeLib

  @doc section: :system_object_type
  @spec create_object_type(map) :: {:ok, SystemObjectType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_object_type(attrs), to: SystemObjectTypeLib

  @doc section: :system_object_type
  @spec update_object_type(SystemObjectType, map) ::
          {:ok, SystemObjectType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_object_type(system_object_type, attrs), to: SystemObjectTypeLib

  @doc section: :system_object_type
  @spec delete_object_type(SystemObjectType.t()) ::
          {:ok, SystemObjectType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_object_type(system_object_type), to: SystemObjectTypeLib

  @doc section: :system_object_type
  @spec change_object_type(SystemObjectType.t(), map) :: Ecto.Changeset.t()
  defdelegate change_object_type(system_object_type, attrs \\ %{}), to: SystemObjectTypeLib

  # StationModuleTypes
  alias Durandal.Types.{StationModuleType, StationModuleTypeLib, StationModuleTypeQueries}

  @doc false
  @spec station_module_type_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate station_module_type_query(args), to: StationModuleTypeQueries

  @doc section: :station_module_type
  @spec list_station_module_types(Durandal.query_args()) :: [StationModuleType.t()]
  defdelegate list_station_module_types(args), to: StationModuleTypeLib

  @doc section: :station_module_type
  @spec get_station_module_type!(StationModuleType.id(), Durandal.query_args()) ::
          StationModuleType.t()
  defdelegate get_station_module_type!(station_module_type_id, query_args \\ []),
    to: StationModuleTypeLib

  @doc section: :station_module_type
  @spec get_station_module_type(StationModuleType.id(), Durandal.query_args()) ::
          StationModuleType.t() | nil
  defdelegate get_station_module_type(station_module_type_id, query_args \\ []),
    to: StationModuleTypeLib

  @doc section: :station_module_type
  @spec create_station_module_type(map) ::
          {:ok, StationModuleType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_station_module_type(attrs), to: StationModuleTypeLib

  @doc section: :station_module_type
  @spec update_station_module_type(StationModuleType, map) ::
          {:ok, StationModuleType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_station_module_type(station_module_type, attrs), to: StationModuleTypeLib

  @doc section: :station_module_type
  @spec delete_station_module_type(StationModuleType.t()) ::
          {:ok, StationModuleType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_station_module_type(station_module_type), to: StationModuleTypeLib

  @doc section: :station_module_type
  @spec change_station_module_type(StationModuleType.t(), map) :: Ecto.Changeset.t()
  defdelegate change_station_module_type(station_module_type, attrs \\ %{}),
    to: StationModuleTypeLib

  # ShipTypes
  alias Durandal.Types.{ShipType, ShipTypeLib, ShipTypeQueries}

  @doc false
  @spec ship_type_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate ship_type_query(args), to: ShipTypeQueries

  @doc section: :ship_type
  @spec list_ship_types(Durandal.query_args()) :: [ShipType.t()]
  defdelegate list_ship_types(args), to: ShipTypeLib

  @doc section: :ship_type
  @spec get_ship_type!(ShipType.id(), Durandal.query_args()) :: ShipType.t()
  defdelegate get_ship_type!(ship_type_id, query_args \\ []), to: ShipTypeLib

  @doc section: :ship_type
  @spec get_ship_type(ShipType.id(), Durandal.query_args()) :: ShipType.t() | nil
  defdelegate get_ship_type(ship_type_id, query_args \\ []), to: ShipTypeLib

  @doc section: :ship_type
  @spec create_ship_type(map) :: {:ok, ShipType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_ship_type(attrs), to: ShipTypeLib

  @doc section: :ship_type
  @spec update_ship_type(ShipType, map) :: {:ok, ShipType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_ship_type(ship_type, attrs), to: ShipTypeLib

  @doc section: :ship_type
  @spec delete_ship_type(ShipType.t()) :: {:ok, ShipType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_ship_type(ship_type), to: ShipTypeLib

  @doc section: :ship_type
  @spec change_ship_type(ShipType.t(), map) :: Ecto.Changeset.t()
  defdelegate change_ship_type(ship_type, attrs \\ %{}), to: ShipTypeLib
end
