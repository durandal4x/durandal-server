defmodule Durandal.Resources do
  @moduledoc """

  """

  # SimpleTypes
  alias Durandal.Resources.{SimpleType, SimpleTypeLib, SimpleTypeQueries}

  @doc false
  @spec simple_type_topic(Durandal.simple_type_id()) :: String.t()
  defdelegate simple_type_topic(simple_type_id), to: SimpleTypeLib, as: :topic

  @doc false
  @spec simple_type_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate simple_type_query(args), to: SimpleTypeQueries

  @doc section: :simple_type
  @spec list_resources_simple_types(Durandal.query_args()) :: [SimpleType.t()]
  defdelegate list_resources_simple_types(args), to: SimpleTypeLib

  @doc section: :simple_type
  @spec get_simple_type!(SimpleType.id(), Durandal.query_args()) :: SimpleType.t()
  defdelegate get_simple_type!(simple_type_id, query_args \\ []), to: SimpleTypeLib

  @doc section: :simple_type
  @spec get_simple_type(SimpleType.id(), Durandal.query_args()) :: SimpleType.t() | nil
  defdelegate get_simple_type(simple_type_id, query_args \\ []), to: SimpleTypeLib

  @doc section: :simple_type
  @spec create_simple_type(map) :: {:ok, SimpleType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_simple_type(attrs), to: SimpleTypeLib

  @doc section: :simple_type
  @spec update_simple_type(SimpleType, map) ::
          {:ok, SimpleType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_simple_type(simple_type, attrs), to: SimpleTypeLib

  @doc section: :simple_type
  @spec delete_simple_type(SimpleType.t()) :: {:ok, SimpleType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_simple_type(simple_type), to: SimpleTypeLib

  @doc section: :simple_type
  @spec change_simple_type(SimpleType.t(), map) :: Ecto.Changeset.t()
  defdelegate change_simple_type(simple_type, attrs \\ %{}), to: SimpleTypeLib

  # SimpleStationModuleInstances
  alias Durandal.Resources.{
    SimpleStationModuleInstance,
    SimpleStationModuleInstanceLib,
    SimpleStationModuleInstanceQueries
  }

  @doc false
  @spec simple_station_module_instance_topic(Durandal.simple_station_module_instance_id()) ::
          String.t()
  defdelegate simple_station_module_instance_topic(simple_station_module_instance_id),
    to: SimpleStationModuleInstanceLib,
    as: :topic

  @doc false
  @spec simple_station_module_instance_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate simple_station_module_instance_query(args), to: SimpleStationModuleInstanceQueries

  @doc section: :simple_station_module_instance
  @spec list_resources_simple_station_module_instances(Durandal.query_args()) :: [
          SimpleStationModuleInstance.t()
        ]
  defdelegate list_resources_simple_station_module_instances(args),
    to: SimpleStationModuleInstanceLib

  @doc section: :simple_station_module_instance
  @spec get_simple_station_module_instance!(
          SimpleStationModuleInstance.id(),
          Durandal.query_args()
        ) :: SimpleStationModuleInstance.t()
  defdelegate get_simple_station_module_instance!(
                simple_station_module_instance_id,
                query_args \\ []
              ),
              to: SimpleStationModuleInstanceLib

  @doc section: :simple_station_module_instance
  @spec get_simple_station_module_instance(
          SimpleStationModuleInstance.id(),
          Durandal.query_args()
        ) :: SimpleStationModuleInstance.t() | nil
  defdelegate get_simple_station_module_instance(
                simple_station_module_instance_id,
                query_args \\ []
              ),
              to: SimpleStationModuleInstanceLib

  @doc section: :simple_station_module_instance
  @spec create_simple_station_module_instance(map) ::
          {:ok, SimpleStationModuleInstance.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_simple_station_module_instance(attrs), to: SimpleStationModuleInstanceLib

  @doc section: :simple_station_module_instance
  @spec update_simple_station_module_instance(SimpleStationModuleInstance, map) ::
          {:ok, SimpleStationModuleInstance.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_simple_station_module_instance(simple_station_module_instance, attrs),
    to: SimpleStationModuleInstanceLib

  @doc section: :simple_station_module_instance
  @spec delete_simple_station_module_instance(SimpleStationModuleInstance.t()) ::
          {:ok, SimpleStationModuleInstance.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_simple_station_module_instance(simple_station_module_instance),
    to: SimpleStationModuleInstanceLib

  @doc section: :simple_station_module_instance
  @spec change_simple_station_module_instance(SimpleStationModuleInstance.t(), map) ::
          Ecto.Changeset.t()
  defdelegate change_simple_station_module_instance(simple_station_module_instance, attrs \\ %{}),
    to: SimpleStationModuleInstanceLib

  # CompositeTypes
  alias Durandal.Resources.{CompositeType, CompositeTypeLib, CompositeTypeQueries}

  @doc false
  @spec composite_type_topic(Durandal.composite_type_id()) :: String.t()
  defdelegate composite_type_topic(composite_type_id), to: CompositeTypeLib, as: :topic

  @doc false
  @spec composite_type_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate composite_type_query(args), to: CompositeTypeQueries

  @doc section: :composite_type
  @spec list_resources_composite_types(Durandal.query_args()) :: [CompositeType.t()]
  defdelegate list_resources_composite_types(args), to: CompositeTypeLib

  @doc section: :composite_type
  @spec get_composite_type!(CompositeType.id(), Durandal.query_args()) :: CompositeType.t()
  defdelegate get_composite_type!(composite_type_id, query_args \\ []), to: CompositeTypeLib

  @doc section: :composite_type
  @spec get_composite_type(CompositeType.id(), Durandal.query_args()) :: CompositeType.t() | nil
  defdelegate get_composite_type(composite_type_id, query_args \\ []), to: CompositeTypeLib

  @doc section: :composite_type
  @spec create_composite_type(map) :: {:ok, CompositeType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_composite_type(attrs), to: CompositeTypeLib

  @doc section: :composite_type
  @spec update_composite_type(CompositeType, map) ::
          {:ok, CompositeType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_composite_type(composite_type, attrs), to: CompositeTypeLib

  @doc section: :composite_type
  @spec delete_composite_type(CompositeType.t()) ::
          {:ok, CompositeType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_composite_type(composite_type), to: CompositeTypeLib

  @doc section: :composite_type
  @spec change_composite_type(CompositeType.t(), map) :: Ecto.Changeset.t()
  defdelegate change_composite_type(composite_type, attrs \\ %{}), to: CompositeTypeLib

  # SimpleShipInstances
  alias Durandal.Resources.{SimpleShipInstance, SimpleShipInstanceLib, SimpleShipInstanceQueries}

  @doc false
  @spec simple_ship_instance_topic(Durandal.simple_ship_instance_id()) :: String.t()
  defdelegate simple_ship_instance_topic(simple_ship_instance_id),
    to: SimpleShipInstanceLib,
    as: :topic

  @doc false
  @spec simple_ship_instance_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate simple_ship_instance_query(args), to: SimpleShipInstanceQueries

  @doc section: :simple_ship_instance
  @spec list_resources_simple_ship_instances(Durandal.query_args()) :: [SimpleShipInstance.t()]
  defdelegate list_resources_simple_ship_instances(args), to: SimpleShipInstanceLib

  @doc section: :simple_ship_instance
  @spec get_simple_ship_instance!(SimpleShipInstance.id(), Durandal.query_args()) ::
          SimpleShipInstance.t()
  defdelegate get_simple_ship_instance!(simple_ship_instance_id, query_args \\ []),
    to: SimpleShipInstanceLib

  @doc section: :simple_ship_instance
  @spec get_simple_ship_instance(SimpleShipInstance.id(), Durandal.query_args()) ::
          SimpleShipInstance.t() | nil
  defdelegate get_simple_ship_instance(simple_ship_instance_id, query_args \\ []),
    to: SimpleShipInstanceLib

  @doc section: :simple_ship_instance
  @spec create_simple_ship_instance(map) ::
          {:ok, SimpleShipInstance.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_simple_ship_instance(attrs), to: SimpleShipInstanceLib

  @doc section: :simple_ship_instance
  @spec update_simple_ship_instance(SimpleShipInstance, map) ::
          {:ok, SimpleShipInstance.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_simple_ship_instance(simple_ship_instance, attrs), to: SimpleShipInstanceLib

  @doc section: :simple_ship_instance
  @spec delete_simple_ship_instance(SimpleShipInstance.t()) ::
          {:ok, SimpleShipInstance.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_simple_ship_instance(simple_ship_instance), to: SimpleShipInstanceLib

  @doc section: :simple_ship_instance
  @spec change_simple_ship_instance(SimpleShipInstance.t(), map) :: Ecto.Changeset.t()
  defdelegate change_simple_ship_instance(simple_ship_instance, attrs \\ %{}),
    to: SimpleShipInstanceLib

  # CompositeStationModuleInstances
  alias Durandal.Resources.{
    CompositeStationModuleInstance,
    CompositeStationModuleInstanceLib,
    CompositeStationModuleInstanceQueries
  }

  @doc false
  @spec composite_station_module_instance_topic(Durandal.composite_station_module_instance_id()) ::
          String.t()
  defdelegate composite_station_module_instance_topic(composite_station_module_instance_id),
    to: CompositeStationModuleInstanceLib,
    as: :topic

  @doc false
  @spec composite_station_module_instance_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate composite_station_module_instance_query(args),
    to: CompositeStationModuleInstanceQueries

  @doc section: :composite_station_module_instance
  @spec list_resources_composite_station_module_instances(Durandal.query_args()) :: [
          CompositeStationModuleInstance.t()
        ]
  defdelegate list_resources_composite_station_module_instances(args),
    to: CompositeStationModuleInstanceLib

  @doc section: :composite_station_module_instance
  @spec get_composite_station_module_instance!(
          CompositeStationModuleInstance.id(),
          Durandal.query_args()
        ) :: CompositeStationModuleInstance.t()
  defdelegate get_composite_station_module_instance!(
                composite_station_module_instance_id,
                query_args \\ []
              ),
              to: CompositeStationModuleInstanceLib

  @doc section: :composite_station_module_instance
  @spec get_composite_station_module_instance(
          CompositeStationModuleInstance.id(),
          Durandal.query_args()
        ) :: CompositeStationModuleInstance.t() | nil
  defdelegate get_composite_station_module_instance(
                composite_station_module_instance_id,
                query_args \\ []
              ),
              to: CompositeStationModuleInstanceLib

  @doc section: :composite_station_module_instance
  @spec create_composite_station_module_instance(map) ::
          {:ok, CompositeStationModuleInstance.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_composite_station_module_instance(attrs),
    to: CompositeStationModuleInstanceLib

  @doc section: :composite_station_module_instance
  @spec update_composite_station_module_instance(CompositeStationModuleInstance, map) ::
          {:ok, CompositeStationModuleInstance.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_composite_station_module_instance(composite_station_module_instance, attrs),
    to: CompositeStationModuleInstanceLib

  @doc section: :composite_station_module_instance
  @spec delete_composite_station_module_instance(CompositeStationModuleInstance.t()) ::
          {:ok, CompositeStationModuleInstance.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_composite_station_module_instance(composite_station_module_instance),
    to: CompositeStationModuleInstanceLib

  @doc section: :composite_station_module_instance
  @spec change_composite_station_module_instance(CompositeStationModuleInstance.t(), map) ::
          Ecto.Changeset.t()
  defdelegate change_composite_station_module_instance(
                composite_station_module_instance,
                attrs \\ %{}
              ),
              to: CompositeStationModuleInstanceLib

  # CompositeShipInstances
  alias Durandal.Resources.{
    CompositeShipInstance,
    CompositeShipInstanceLib,
    CompositeShipInstanceQueries
  }

  @doc false
  @spec composite_ship_instance_topic(Durandal.composite_ship_instance_id()) :: String.t()
  defdelegate composite_ship_instance_topic(composite_ship_instance_id),
    to: CompositeShipInstanceLib,
    as: :topic

  @doc false
  @spec composite_ship_instance_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate composite_ship_instance_query(args), to: CompositeShipInstanceQueries

  @doc section: :composite_ship_instance
  @spec list_resources_composite_ship_instances(Durandal.query_args()) :: [
          CompositeShipInstance.t()
        ]
  defdelegate list_resources_composite_ship_instances(args), to: CompositeShipInstanceLib

  @doc section: :composite_ship_instance
  @spec get_composite_ship_instance!(CompositeShipInstance.id(), Durandal.query_args()) ::
          CompositeShipInstance.t()
  defdelegate get_composite_ship_instance!(composite_ship_instance_id, query_args \\ []),
    to: CompositeShipInstanceLib

  @doc section: :composite_ship_instance
  @spec get_composite_ship_instance(CompositeShipInstance.id(), Durandal.query_args()) ::
          CompositeShipInstance.t() | nil
  defdelegate get_composite_ship_instance(composite_ship_instance_id, query_args \\ []),
    to: CompositeShipInstanceLib

  @doc section: :composite_ship_instance
  @spec create_composite_ship_instance(map) ::
          {:ok, CompositeShipInstance.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_composite_ship_instance(attrs), to: CompositeShipInstanceLib

  @doc section: :composite_ship_instance
  @spec update_composite_ship_instance(CompositeShipInstance, map) ::
          {:ok, CompositeShipInstance.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_composite_ship_instance(composite_ship_instance, attrs),
    to: CompositeShipInstanceLib

  @doc section: :composite_ship_instance
  @spec delete_composite_ship_instance(CompositeShipInstance.t()) ::
          {:ok, CompositeShipInstance.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_composite_ship_instance(composite_ship_instance),
    to: CompositeShipInstanceLib

  @doc section: :composite_ship_instance
  @spec change_composite_ship_instance(CompositeShipInstance.t(), map) :: Ecto.Changeset.t()
  defdelegate change_composite_ship_instance(composite_ship_instance, attrs \\ %{}),
    to: CompositeShipInstanceLib
end
