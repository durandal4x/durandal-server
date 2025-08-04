defmodule Durandal.Resources.SimpleTypeLib do
  @moduledoc """
  Library of simple_type related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Resources.{SimpleType, SimpleTypeQueries}

  @spec topic(Durandal.simple_type_id()) :: String.t()
  def topic(simple_type_id), do: "Durandal.Resources.SimpleType:#{simple_type_id}"

  @doc """
  Returns the list of resources_simple_types.

  ## Examples

      iex> list_simple_types()
      [%SimpleType{}, ...]

  """
  @spec list_simple_types(Durandal.query_args()) :: [SimpleType.t()]
  def list_simple_types(query_args) do
    query_args
    |> SimpleTypeQueries.simple_type_query()
    |> Repo.all()
  end

  @doc """
  Gets a single simple_type.

  Raises `Ecto.NoResultsError` if the SimpleType does not exist.

  ## Examples

      iex> get_simple_type!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %SimpleType{}

      iex> get_simple_type!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_simple_type!(SimpleType.id(), Durandal.query_args()) :: SimpleType.t()
  def get_simple_type!(simple_type_id, query_args \\ []) do
    (query_args ++ [id: simple_type_id])
    |> SimpleTypeQueries.simple_type_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single simple_type.

  Returns nil if the SimpleType does not exist.

  ## Examples

      iex> get_simple_type("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %SimpleType{}

      iex> get_simple_type("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_simple_type(SimpleType.id(), Durandal.query_args()) :: SimpleType.t() | nil
  def get_simple_type(simple_type_id, query_args \\ []) do
    (query_args ++ [id: simple_type_id])
    |> SimpleTypeQueries.simple_type_query()
    |> Repo.one()
  end

  @doc """
  Creates a simple_type.

  ## Examples

      iex> create_simple_type(%{field: value})
      {:ok, %SimpleType{}}

      iex> create_simple_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_simple_type(map) :: {:ok, SimpleType.t()} | {:error, Ecto.Changeset.t()}
  def create_simple_type(attrs) do
    %SimpleType{}
    |> SimpleType.changeset(attrs)
    |> Repo.insert()
    |> Durandal.broadcast_on_ok(&topic/1, :simple_type, %{event: :created_simple_type})
    |> Durandal.broadcast_on_ok(
      {&Durandal.Game.UniverseLib.topic/1, :universe_id},
      :simple_type,
      %{event: :created_simple_type}
    )
  end

  @doc """
  Updates a simple_type.

  ## Examples

      iex> update_simple_type(simple_type, %{field: new_value})
      {:ok, %SimpleType{}}

      iex> update_simple_type(simple_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_simple_type(SimpleType.t(), map) ::
          {:ok, SimpleType.t()} | {:error, Ecto.Changeset.t()}
  def update_simple_type(%SimpleType{} = simple_type, attrs) do
    simple_type
    |> SimpleType.changeset(attrs)
    |> Repo.update()
    |> Durandal.broadcast_on_ok(&topic/1, :simple_type, %{event: :updated_simple_type})
    |> Durandal.broadcast_on_ok(
      {&Durandal.Game.UniverseLib.topic/1, :universe_id},
      :simple_type,
      %{event: :updated_simple_type}
    )
  end

  @doc """
  Deletes a simple_type.

  ## Examples

      iex> delete_simple_type(simple_type)
      {:ok, %SimpleType{}}

      iex> delete_simple_type(simple_type)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_simple_type(SimpleType.t()) :: {:ok, SimpleType.t()} | {:error, Ecto.Changeset.t()}
  def delete_simple_type(%SimpleType{} = simple_type) do
    Repo.delete(simple_type)
    |> Durandal.broadcast_on_ok(&topic/1, :simple_type, %{event: :deleted_simple_type})
    |> Durandal.broadcast_on_ok(
      {&Durandal.Game.UniverseLib.topic/1, :universe_id},
      :simple_type,
      %{event: :deleted_simple_type}
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking simple_type changes.

  ## Examples

      iex> change_simple_type(simple_type)
      %Ecto.Changeset{data: %SimpleType{}}

  """
  @spec change_simple_type(SimpleType.t(), map) :: Ecto.Changeset.t()
  def change_simple_type(%SimpleType{} = simple_type, attrs \\ %{}) do
    SimpleType.changeset(simple_type, attrs)
  end
end
