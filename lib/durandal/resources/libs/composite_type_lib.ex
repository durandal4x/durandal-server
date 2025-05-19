defmodule Durandal.Resources.CompositeTypeLib do
  @moduledoc """
  Library of composite_type related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Resources.{CompositeType, CompositeTypeQueries}

  @spec topic(Durandal.composite_type_id()) :: String.t()
  def topic(composite_type_id), do: "Durandal.Resources.CompositeType:#{composite_type_id}"

  @doc """
  Returns the list of resources_composite_types.

  ## Examples

      iex> list_resources_composite_types()
      [%CompositeType{}, ...]

  """
  @spec list_resources_composite_types(Durandal.query_args()) :: [CompositeType.t()]
  def list_resources_composite_types(query_args) do
    query_args
    |> CompositeTypeQueries.composite_type_query()
    |> Repo.all()
  end

  @doc """
  Gets a single composite_type.

  Raises `Ecto.NoResultsError` if the CompositeType does not exist.

  ## Examples

      iex> get_composite_type!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %CompositeType{}

      iex> get_composite_type!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_composite_type!(CompositeType.id(), Durandal.query_args()) :: CompositeType.t()
  def get_composite_type!(composite_type_id, query_args \\ []) do
    (query_args ++ [id: composite_type_id])
    |> CompositeTypeQueries.composite_type_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single composite_type.

  Returns nil if the CompositeType does not exist.

  ## Examples

      iex> get_composite_type("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %CompositeType{}

      iex> get_composite_type("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_composite_type(CompositeType.id(), Durandal.query_args()) :: CompositeType.t() | nil
  def get_composite_type(composite_type_id, query_args \\ []) do
    (query_args ++ [id: composite_type_id])
    |> CompositeTypeQueries.composite_type_query()
    |> Repo.one()
  end

  @doc """
  Creates a composite_type.

  ## Examples

      iex> create_composite_type(%{field: value})
      {:ok, %CompositeType{}}

      iex> create_composite_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_composite_type(map) :: {:ok, CompositeType.t()} | {:error, Ecto.Changeset.t()}
  def create_composite_type(attrs) do
    %CompositeType{}
    |> CompositeType.changeset(attrs)
    |> Repo.insert()
    |> Durandal.broadcast_on_ok(&topic/1, :composite_type, %{event: :created_composite_type})
    |> Durandal.broadcast_on_ok(
      {&Durandal.Game.UniverseLib.topic/1, :foreign_key_id},
      :composite_type,
      %{event: :created_composite_type}
    )
  end

  @doc """
  Updates a composite_type.

  ## Examples

      iex> update_composite_type(composite_type, %{field: new_value})
      {:ok, %CompositeType{}}

      iex> update_composite_type(composite_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_composite_type(CompositeType.t(), map) ::
          {:ok, CompositeType.t()} | {:error, Ecto.Changeset.t()}
  def update_composite_type(%CompositeType{} = composite_type, attrs) do
    composite_type
    |> CompositeType.changeset(attrs)
    |> Repo.update()
    |> Durandal.broadcast_on_ok(&topic/1, :composite_type, %{event: :updated_composite_type})
    |> Durandal.broadcast_on_ok(
      {&Durandal.Game.UniverseLib.topic/1, :foreign_key_id},
      :composite_type,
      %{event: :updated_composite_type}
    )
  end

  @doc """
  Deletes a composite_type.

  ## Examples

      iex> delete_composite_type(composite_type)
      {:ok, %CompositeType{}}

      iex> delete_composite_type(composite_type)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_composite_type(CompositeType.t()) ::
          {:ok, CompositeType.t()} | {:error, Ecto.Changeset.t()}
  def delete_composite_type(%CompositeType{} = composite_type) do
    Repo.delete(composite_type)
    |> Durandal.broadcast_on_ok(&topic/1, :composite_type, %{event: :deleted_composite_type})
    |> Durandal.broadcast_on_ok(
      {&Durandal.Game.UniverseLib.topic/1, :foreign_key_id},
      :composite_type,
      %{event: :deleted_composite_type}
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking composite_type changes.

  ## Examples

      iex> change_composite_type(composite_type)
      %Ecto.Changeset{data: %CompositeType{}}

  """
  @spec change_composite_type(CompositeType.t(), map) :: Ecto.Changeset.t()
  def change_composite_type(%CompositeType{} = composite_type, attrs \\ %{}) do
    CompositeType.changeset(composite_type, attrs)
  end
end
