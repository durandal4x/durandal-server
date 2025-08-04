defmodule Durandal.Resources.SimpleStationModuleInstanceLib do
  @moduledoc """
  Library of simple_station_module_instance related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Resources.{SimpleStationModuleInstance, SimpleStationModuleInstanceQueries}

  @spec topic(Durandal.simple_station_module_instance_id()) :: String.t()
  def topic(simple_station_module_instance_id),
    do: "Durandal.Resources.SimpleStationModuleInstance:#{simple_station_module_instance_id}"

  defdelegate parent_topic(parent_id), to: Durandal.Space.StationModuleLib, as: :topic

  @doc """
  Returns the list of resources_simple_station_module_instances.

  ## Examples

      iex> list_simple_station_module_instances()
      [%SimpleStationModuleInstance{}, ...]

  """
  @spec list_simple_station_module_instances(Durandal.query_args()) :: [
          SimpleStationModuleInstance.t()
        ]
  def list_simple_station_module_instances(query_args) do
    query_args
    |> SimpleStationModuleInstanceQueries.simple_station_module_instance_query()
    |> Repo.all()
  end

  @doc """
  Gets a single simple_station_module_instance.

  Raises `Ecto.NoResultsError` if the SimpleStationModuleInstance does not exist.

  ## Examples

      iex> get_simple_station_module_instance!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %SimpleStationModuleInstance{}

      iex> get_simple_station_module_instance!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_simple_station_module_instance!(
          SimpleStationModuleInstance.id(),
          Durandal.query_args()
        ) :: SimpleStationModuleInstance.t()
  def get_simple_station_module_instance!(simple_station_module_instance_id, query_args \\ []) do
    (query_args ++ [id: simple_station_module_instance_id])
    |> SimpleStationModuleInstanceQueries.simple_station_module_instance_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single simple_station_module_instance.

  Returns nil if the SimpleStationModuleInstance does not exist.

  ## Examples

      iex> get_simple_station_module_instance("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %SimpleStationModuleInstance{}

      iex> get_simple_station_module_instance("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_simple_station_module_instance(
          SimpleStationModuleInstance.id(),
          Durandal.query_args()
        ) :: SimpleStationModuleInstance.t() | nil
  def get_simple_station_module_instance(simple_station_module_instance_id, query_args \\ []) do
    (query_args ++ [id: simple_station_module_instance_id])
    |> SimpleStationModuleInstanceQueries.simple_station_module_instance_query()
    |> Repo.one()
  end

  @doc """
  Creates a simple_station_module_instance.

  ## Examples

      iex> create_simple_station_module_instance(%{field: value})
      {:ok, %SimpleStationModuleInstance{}}

      iex> create_simple_station_module_instance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_simple_station_module_instance(map) ::
          {:ok, SimpleStationModuleInstance.t()} | {:error, Ecto.Changeset.t()}
  def create_simple_station_module_instance(attrs) do
    %SimpleStationModuleInstance{}
    |> SimpleStationModuleInstance.changeset(attrs)
    |> Repo.insert()
    |> Durandal.broadcast_on_ok(&topic/1, :simple_station_module_instance, %{
      event: :created_simple_station_module_instance
    })
    |> Durandal.broadcast_on_ok(
      {&Durandal.Space.StationModuleLib.topic/1, :station_module_id},
      :simple_station_module_instance,
      %{event: :created_simple_station_module_instance}
    )
  end

  @doc """
  Updates a simple_station_module_instance.

  ## Examples

      iex> update_simple_station_module_instance(simple_station_module_instance, %{field: new_value})
      {:ok, %SimpleStationModuleInstance{}}

      iex> update_simple_station_module_instance(simple_station_module_instance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_simple_station_module_instance(SimpleStationModuleInstance.t(), map) ::
          {:ok, SimpleStationModuleInstance.t()} | {:error, Ecto.Changeset.t()}
  def update_simple_station_module_instance(
        %SimpleStationModuleInstance{} = simple_station_module_instance,
        attrs
      ) do
    simple_station_module_instance
    |> SimpleStationModuleInstance.changeset(attrs)
    |> Repo.update()
    |> Durandal.broadcast_on_ok(&topic/1, :simple_station_module_instance, %{
      event: :updated_simple_station_module_instance
    })
    |> Durandal.broadcast_on_ok(
      {&Durandal.Space.StationModuleLib.topic/1, :station_module_id},
      :simple_station_module_instance,
      %{event: :updated_simple_station_module_instance}
    )
  end

  @doc """
  Deletes a simple_station_module_instance.

  ## Examples

      iex> delete_simple_station_module_instance(simple_station_module_instance)
      {:ok, %SimpleStationModuleInstance{}}

      iex> delete_simple_station_module_instance(simple_station_module_instance)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_simple_station_module_instance(SimpleStationModuleInstance.t()) ::
          {:ok, SimpleStationModuleInstance.t()} | {:error, Ecto.Changeset.t()}
  def delete_simple_station_module_instance(
        %SimpleStationModuleInstance{} = simple_station_module_instance
      ) do
    Repo.delete(simple_station_module_instance)
    |> Durandal.broadcast_on_ok(&topic/1, :simple_station_module_instance, %{
      event: :deleted_simple_station_module_instance
    })
    |> Durandal.broadcast_on_ok(
      {&Durandal.Space.StationModuleLib.topic/1, :station_module_id},
      :simple_station_module_instance,
      %{event: :deleted_simple_station_module_instance}
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking simple_station_module_instance changes.

  ## Examples

      iex> change_simple_station_module_instance(simple_station_module_instance)
      %Ecto.Changeset{data: %SimpleStationModuleInstance{}}

  """
  @spec change_simple_station_module_instance(SimpleStationModuleInstance.t(), map) ::
          Ecto.Changeset.t()
  def change_simple_station_module_instance(
        %SimpleStationModuleInstance{} = simple_station_module_instance,
        attrs \\ %{}
      ) do
    SimpleStationModuleInstance.changeset(simple_station_module_instance, attrs)
  end
end
