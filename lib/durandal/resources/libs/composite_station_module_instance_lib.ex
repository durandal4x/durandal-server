defmodule Durandal.Resources.CompositeStationModuleInstanceLib do
  @moduledoc """
  Library of composite_station_module_instance related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Resources.{CompositeStationModuleInstance, CompositeStationModuleInstanceQueries}

  @spec topic(Durandal.composite_station_module_instance_id()) :: String.t()
  def topic(composite_station_module_instance_id),
    do:
      "Durandal.Resources.CompositeStationModuleInstance:#{composite_station_module_instance_id}"

  defdelegate parent_topic(parent_id), to: Durandal.Space.StationModuleLib, as: :topic

  @doc """
  Returns the list of resources_composite_station_module_instances.

  ## Examples

      iex> list_composite_station_module_instances()
      [%CompositeStationModuleInstance{}, ...]

  """
  @spec list_composite_station_module_instances(Durandal.query_args()) :: [
          CompositeStationModuleInstance.t()
        ]
  def list_composite_station_module_instances(query_args) do
    query_args
    |> CompositeStationModuleInstanceQueries.composite_station_module_instance_query()
    |> Repo.all()
  end

  @doc """
  Gets a single composite_station_module_instance.

  Raises `Ecto.NoResultsError` if the CompositeStationModuleInstance does not exist.

  ## Examples

      iex> get_composite_station_module_instance!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %CompositeStationModuleInstance{}

      iex> get_composite_station_module_instance!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_composite_station_module_instance!(
          CompositeStationModuleInstance.id(),
          Durandal.query_args()
        ) :: CompositeStationModuleInstance.t()
  def get_composite_station_module_instance!(
        composite_station_module_instance_id,
        query_args \\ []
      ) do
    (query_args ++ [id: composite_station_module_instance_id])
    |> CompositeStationModuleInstanceQueries.composite_station_module_instance_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single composite_station_module_instance.

  Returns nil if the CompositeStationModuleInstance does not exist.

  ## Examples

      iex> get_composite_station_module_instance("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %CompositeStationModuleInstance{}

      iex> get_composite_station_module_instance("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_composite_station_module_instance(
          CompositeStationModuleInstance.id(),
          Durandal.query_args()
        ) :: CompositeStationModuleInstance.t() | nil
  def get_composite_station_module_instance(
        composite_station_module_instance_id,
        query_args \\ []
      ) do
    (query_args ++ [id: composite_station_module_instance_id])
    |> CompositeStationModuleInstanceQueries.composite_station_module_instance_query()
    |> Repo.one()
  end

  @doc """
  Creates a composite_station_module_instance.

  ## Examples

      iex> create_composite_station_module_instance(%{field: value})
      {:ok, %CompositeStationModuleInstance{}}

      iex> create_composite_station_module_instance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_composite_station_module_instance(map) ::
          {:ok, CompositeStationModuleInstance.t()} | {:error, Ecto.Changeset.t()}
  def create_composite_station_module_instance(attrs) do
    %CompositeStationModuleInstance{}
    |> CompositeStationModuleInstance.changeset(attrs)
    |> Repo.insert()
    |> Durandal.broadcast_on_ok(&topic/1, :composite_station_module_instance, %{
      event: :created_composite_station_module_instance
    })
    |> Durandal.broadcast_on_ok(
      {&parent_topic/1, :foreign_key_id},
      :composite_station_module_instance,
      %{event: :created_composite_station_module_instance}
    )
  end

  @doc """
  Updates a composite_station_module_instance.

  ## Examples

      iex> update_composite_station_module_instance(composite_station_module_instance, %{field: new_value})
      {:ok, %CompositeStationModuleInstance{}}

      iex> update_composite_station_module_instance(composite_station_module_instance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_composite_station_module_instance(CompositeStationModuleInstance.t(), map) ::
          {:ok, CompositeStationModuleInstance.t()} | {:error, Ecto.Changeset.t()}
  def update_composite_station_module_instance(
        %CompositeStationModuleInstance{} = composite_station_module_instance,
        attrs
      ) do
    composite_station_module_instance
    |> CompositeStationModuleInstance.changeset(attrs)
    |> Repo.update()
    |> Durandal.broadcast_on_ok(&topic/1, :composite_station_module_instance, %{
      event: :updated_composite_station_module_instance
    })
    |> Durandal.broadcast_on_ok(
      {&parent_topic/1, :foreign_key_id},
      :composite_station_module_instance,
      %{event: :updated_composite_station_module_instance}
    )
  end

  @doc """
  Deletes a composite_station_module_instance.

  ## Examples

      iex> delete_composite_station_module_instance(composite_station_module_instance)
      {:ok, %CompositeStationModuleInstance{}}

      iex> delete_composite_station_module_instance(composite_station_module_instance)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_composite_station_module_instance(CompositeStationModuleInstance.t()) ::
          {:ok, CompositeStationModuleInstance.t()} | {:error, Ecto.Changeset.t()}
  def delete_composite_station_module_instance(
        %CompositeStationModuleInstance{} = composite_station_module_instance
      ) do
    Repo.delete(composite_station_module_instance)
    |> Durandal.broadcast_on_ok(&topic/1, :composite_station_module_instance, %{
      event: :deleted_composite_station_module_instance
    })
    |> Durandal.broadcast_on_ok(
      {&parent_topic/1, :foreign_key_id},
      :composite_station_module_instance,
      %{event: :deleted_composite_station_module_instance}
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking composite_station_module_instance changes.

  ## Examples

      iex> change_composite_station_module_instance(composite_station_module_instance)
      %Ecto.Changeset{data: %CompositeStationModuleInstance{}}

  """
  @spec change_composite_station_module_instance(CompositeStationModuleInstance.t(), map) ::
          Ecto.Changeset.t()
  def change_composite_station_module_instance(
        %CompositeStationModuleInstance{} = composite_station_module_instance,
        attrs \\ %{}
      ) do
    CompositeStationModuleInstance.changeset(composite_station_module_instance, attrs)
  end
end
