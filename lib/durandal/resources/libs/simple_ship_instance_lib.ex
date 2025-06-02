defmodule Durandal.Resources.SimpleShipInstanceLib do
  @moduledoc """
  Library of simple_ship_instance related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Resources.{SimpleShipInstance, SimpleShipInstanceQueries}

  @spec topic(Durandal.simple_ship_instance_id()) :: String.t()
  def topic(simple_ship_instance_id),
    do: "Durandal.Resources.SimpleShipInstance:#{simple_ship_instance_id}"

  defdelegate parent_topic(parent_id), to: Durandal.Space.ShipLib, as: :topic

  @doc """
  Returns the list of resources_simple_ship_instances.

  ## Examples

      iex> list_simple_ship_instances()
      [%SimpleShipInstance{}, ...]

  """
  @spec list_simple_ship_instances(Durandal.query_args()) :: [SimpleShipInstance.t()]
  def list_simple_ship_instances(query_args) do
    query_args
    |> SimpleShipInstanceQueries.simple_ship_instance_query()
    |> Repo.all()
  end

  @doc """
  Gets a single simple_ship_instance.

  Raises `Ecto.NoResultsError` if the SimpleShipInstance does not exist.

  ## Examples

      iex> get_simple_ship_instance!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %SimpleShipInstance{}

      iex> get_simple_ship_instance!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_simple_ship_instance!(SimpleShipInstance.id(), Durandal.query_args()) ::
          SimpleShipInstance.t()
  def get_simple_ship_instance!(simple_ship_instance_id, query_args \\ []) do
    (query_args ++ [id: simple_ship_instance_id])
    |> SimpleShipInstanceQueries.simple_ship_instance_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single simple_ship_instance.

  Returns nil if the SimpleShipInstance does not exist.

  ## Examples

      iex> get_simple_ship_instance("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %SimpleShipInstance{}

      iex> get_simple_ship_instance("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_simple_ship_instance(SimpleShipInstance.id(), Durandal.query_args()) ::
          SimpleShipInstance.t() | nil
  def get_simple_ship_instance(simple_ship_instance_id, query_args \\ []) do
    (query_args ++ [id: simple_ship_instance_id])
    |> SimpleShipInstanceQueries.simple_ship_instance_query()
    |> Repo.one()
  end

  @doc """
  Creates a simple_ship_instance.

  ## Examples

      iex> create_simple_ship_instance(%{field: value})
      {:ok, %SimpleShipInstance{}}

      iex> create_simple_ship_instance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_simple_ship_instance(map) ::
          {:ok, SimpleShipInstance.t()} | {:error, Ecto.Changeset.t()}
  def create_simple_ship_instance(attrs) do
    %SimpleShipInstance{}
    |> SimpleShipInstance.changeset(attrs)
    |> Repo.insert()
    |> Durandal.broadcast_on_ok(&topic/1, :simple_ship_instance, %{
      event: :created_simple_ship_instance
    })
    |> Durandal.broadcast_on_ok(
      {&parent_topic/1, :foreign_key_id},
      :simple_ship_instance,
      %{event: :created_simple_ship_instance}
    )
  end

  @doc """
  Updates a simple_ship_instance.

  ## Examples

      iex> update_simple_ship_instance(simple_ship_instance, %{field: new_value})
      {:ok, %SimpleShipInstance{}}

      iex> update_simple_ship_instance(simple_ship_instance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_simple_ship_instance(SimpleShipInstance.t(), map) ::
          {:ok, SimpleShipInstance.t()} | {:error, Ecto.Changeset.t()}
  def update_simple_ship_instance(%SimpleShipInstance{} = simple_ship_instance, attrs) do
    simple_ship_instance
    |> SimpleShipInstance.changeset(attrs)
    |> Repo.update()
    |> Durandal.broadcast_on_ok(&topic/1, :simple_ship_instance, %{
      event: :updated_simple_ship_instance
    })
    |> Durandal.broadcast_on_ok(
      {&parent_topic/1, :foreign_key_id},
      :simple_ship_instance,
      %{event: :updated_simple_ship_instance}
    )
  end

  @doc """
  Deletes a simple_ship_instance.

  ## Examples

      iex> delete_simple_ship_instance(simple_ship_instance)
      {:ok, %SimpleShipInstance{}}

      iex> delete_simple_ship_instance(simple_ship_instance)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_simple_ship_instance(SimpleShipInstance.t()) ::
          {:ok, SimpleShipInstance.t()} | {:error, Ecto.Changeset.t()}
  def delete_simple_ship_instance(%SimpleShipInstance{} = simple_ship_instance) do
    Repo.delete(simple_ship_instance)
    |> Durandal.broadcast_on_ok(&topic/1, :simple_ship_instance, %{
      event: :deleted_simple_ship_instance
    })
    |> Durandal.broadcast_on_ok(
      {&parent_topic/1, :foreign_key_id},
      :simple_ship_instance,
      %{event: :deleted_simple_ship_instance}
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking simple_ship_instance changes.

  ## Examples

      iex> change_simple_ship_instance(simple_ship_instance)
      %Ecto.Changeset{data: %SimpleShipInstance{}}

  """
  @spec change_simple_ship_instance(SimpleShipInstance.t(), map) :: Ecto.Changeset.t()
  def change_simple_ship_instance(%SimpleShipInstance{} = simple_ship_instance, attrs \\ %{}) do
    SimpleShipInstance.changeset(simple_ship_instance, attrs)
  end
end
