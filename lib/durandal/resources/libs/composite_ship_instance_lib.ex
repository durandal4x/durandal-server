defmodule Durandal.Resources.CompositeShipInstanceLib do
  @moduledoc """
  Library of composite_ship_instance related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Resources.{CompositeShipInstance, CompositeShipInstanceQueries}

  @spec topic(Durandal.composite_ship_instance_id()) :: String.t()
  def topic(composite_ship_instance_id),
    do: "Durandal.Resources.CompositeShipInstance:#{composite_ship_instance_id}"

  defdelegate parent_topic(parent_id), to: Durandal.Space.ShipLib, as: :topic

  @doc """
  Returns the list of resources_composite_ship_instances.

  ## Examples

      iex> list_composite_ship_instances()
      [%CompositeShipInstance{}, ...]

  """
  @spec list_composite_ship_instances(Durandal.query_args()) :: [
          CompositeShipInstance.t()
        ]
  def list_composite_ship_instances(query_args) do
    query_args
    |> CompositeShipInstanceQueries.composite_ship_instance_query()
    |> Repo.all()
  end

  @doc """
  Gets a single composite_ship_instance.

  Raises `Ecto.NoResultsError` if the CompositeShipInstance does not exist.

  ## Examples

      iex> get_composite_ship_instance!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %CompositeShipInstance{}

      iex> get_composite_ship_instance!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_composite_ship_instance!(CompositeShipInstance.id(), Durandal.query_args()) ::
          CompositeShipInstance.t()
  def get_composite_ship_instance!(composite_ship_instance_id, query_args \\ []) do
    (query_args ++ [id: composite_ship_instance_id])
    |> CompositeShipInstanceQueries.composite_ship_instance_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single composite_ship_instance.

  Returns nil if the CompositeShipInstance does not exist.

  ## Examples

      iex> get_composite_ship_instance("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %CompositeShipInstance{}

      iex> get_composite_ship_instance("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_composite_ship_instance(CompositeShipInstance.id(), Durandal.query_args()) ::
          CompositeShipInstance.t() | nil
  def get_composite_ship_instance(composite_ship_instance_id, query_args \\ []) do
    (query_args ++ [id: composite_ship_instance_id])
    |> CompositeShipInstanceQueries.composite_ship_instance_query()
    |> Repo.one()
  end

  @doc """
  Creates a composite_ship_instance.

  ## Examples

      iex> create_composite_ship_instance(%{field: value})
      {:ok, %CompositeShipInstance{}}

      iex> create_composite_ship_instance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_composite_ship_instance(map) ::
          {:ok, CompositeShipInstance.t()} | {:error, Ecto.Changeset.t()}
  def create_composite_ship_instance(attrs) do
    %CompositeShipInstance{}
    |> CompositeShipInstance.changeset(attrs)
    |> Repo.insert()
    |> Durandal.broadcast_on_ok(&topic/1, :composite_ship_instance, %{
      event: :created_composite_ship_instance
    })
    |> Durandal.broadcast_on_ok(
      {&Durandal.Space.ShipLib.topic/1, :ship_id},
      :composite_ship_instance,
      %{event: :created_composite_ship_instance}
    )
  end

  @doc """
  Updates a composite_ship_instance.

  ## Examples

      iex> update_composite_ship_instance(composite_ship_instance, %{field: new_value})
      {:ok, %CompositeShipInstance{}}

      iex> update_composite_ship_instance(composite_ship_instance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_composite_ship_instance(CompositeShipInstance.t(), map) ::
          {:ok, CompositeShipInstance.t()} | {:error, Ecto.Changeset.t()}
  def update_composite_ship_instance(%CompositeShipInstance{} = composite_ship_instance, attrs) do
    composite_ship_instance
    |> CompositeShipInstance.changeset(attrs)
    |> Repo.update()
    |> Durandal.broadcast_on_ok(&topic/1, :composite_ship_instance, %{
      event: :updated_composite_ship_instance
    })
    |> Durandal.broadcast_on_ok(
      {&parent_topic/1, :foreign_key_id},
      :composite_ship_instance,
      %{event: :updated_composite_ship_instance}
    )
  end

  @doc """
  Deletes a composite_ship_instance.

  ## Examples

      iex> delete_composite_ship_instance(composite_ship_instance)
      {:ok, %CompositeShipInstance{}}

      iex> delete_composite_ship_instance(composite_ship_instance)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_composite_ship_instance(CompositeShipInstance.t()) ::
          {:ok, CompositeShipInstance.t()} | {:error, Ecto.Changeset.t()}
  def delete_composite_ship_instance(%CompositeShipInstance{} = composite_ship_instance) do
    Repo.delete(composite_ship_instance)
    |> Durandal.broadcast_on_ok(&topic/1, :composite_ship_instance, %{
      event: :deleted_composite_ship_instance
    })
    |> Durandal.broadcast_on_ok(
      {&parent_topic/1, :foreign_key_id},
      :composite_ship_instance,
      %{event: :deleted_composite_ship_instance}
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking composite_ship_instance changes.

  ## Examples

      iex> change_composite_ship_instance(composite_ship_instance)
      %Ecto.Changeset{data: %CompositeShipInstance{}}

  """
  @spec change_composite_ship_instance(CompositeShipInstance.t(), map) :: Ecto.Changeset.t()
  def change_composite_ship_instance(
        %CompositeShipInstance{} = composite_ship_instance,
        attrs \\ %{}
      ) do
    CompositeShipInstance.changeset(composite_ship_instance, attrs)
  end
end
