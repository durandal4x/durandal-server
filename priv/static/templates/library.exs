defmodule Application.Context.ObjectLib do
  @moduledoc """
  Library of object related functions.
  """
  use ApplicationMacros, :library
  alias Application.Context.{Object, ObjectQueries}

  @doc """
  Returns the list of objects.

  ## Examples

      iex> list_objects()
      [%Object{}, ...]

  """
  @spec list_objects(Application.query_args()) :: [Object.t()]
  def list_objects(query_args) do
    query_args
    |> ObjectQueries.object_query()
    |> Repo.all()
  end

  @doc """
  Gets a single object.

  Raises `Ecto.NoResultsError` if the Object does not exist.

  ## Examples

      iex> get_object!(123)
      %Object{}

      iex> get_object!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_object!(Object.id(), Application.query_args()) :: Object.t()
  def get_object!(object_id, query_args \\ []) do
    (query_args ++ [id: object_id])
    |> ObjectQueries.object_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single object.

  Returns nil if the Object does not exist.

  ## Examples

      iex> get_object(123)
      %Object{}

      iex> get_object(456)
      nil

  """
  @spec get_object(Object.id(), Application.query_args()) :: Object.t() | nil
  def get_object(object_id, query_args \\ []) do
    (query_args ++ [id: object_id])
    |> ObjectQueries.object_query()
    |> Repo.one
  end

  @doc """
  Creates a object.

  ## Examples

      iex> create_object(%{field: value})
      {:ok, %Object{}}

      iex> create_object(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_object(map) :: {:ok, Object.t} | {:error, Ecto.Changeset.t}
  def create_object(attrs) do
    %Object{}
    |> Object.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a object.

  ## Examples

      iex> update_object(object, %{field: new_value})
      {:ok, %Object{}}

      iex> update_object(object, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_object(Object.t, map) :: {:ok, Object.t} | {:error, Ecto.Changeset.t}
  def update_object(%Object{} = object, attrs) do
    object
    |> Object.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a object.

  ## Examples

      iex> delete_object(object)
      {:ok, %Object{}}

      iex> delete_object(object)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_object(Object.t) :: {:ok, Object.t} | {:error, Ecto.Changeset.t}
  def delete_object(%Object{} = object) do
    Repo.delete(object)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking object changes.

  ## Examples

      iex> change_object(object)
      %Ecto.Changeset{data: %Object{}}

  """
  @spec change_object(Object.t, map) :: Ecto.Changeset.t
  def change_object(%Object{} = object, attrs \\ %{}) do
    Object.changeset(object, attrs)
  end
end
