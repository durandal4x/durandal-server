defmodule $Application.$Context.$ObjectLib do
  @moduledoc """
  Library of $object related functions.
  """
  use $ApplicationMacros, :library
  alias $Application.$Context.{$Object, $ObjectQueries}

  @doc """
  Returns the list of $objects.

  ## Examples

      iex> list_$objects()
      [%$Object{}, ...]

  """
  @spec list_$objects($Application.query_args()) :: [$Object.t()]
  def list_$objects(query_args) do
    query_args
    |> $ObjectQueries.$object_query()
    |> Repo.all()
  end

  @doc """
  Gets a single $object.

  Raises `Ecto.NoResultsError` if the $Object does not exist.

  ## Examples

      iex> get_$object!("$uuid1")
      %$Object{}

      iex> get_$object!("$uuid2")
      ** (Ecto.NoResultsError)

  """
  @spec get_$object!($Object.id(), $Application.query_args()) :: $Object.t()
  def get_$object!($object_id, query_args \\ []) do
    (query_args ++ [id: $object_id])
    |> $ObjectQueries.$object_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single $object.

  Returns nil if the $Object does not exist.

  ## Examples

      iex> get_$object("$uuid1")
      %$Object{}

      iex> get_$object("$uuid2")
      nil

  """
  @spec get_$object($Object.id(), $Application.query_args()) :: $Object.t() | nil
  def get_$object($object_id, query_args \\ []) do
    (query_args ++ [id: $object_id])
    |> $ObjectQueries.$object_query()
    |> Repo.one
  end

  @doc """
  Creates a $object.

  ## Examples

      iex> create_$object(%{field: value})
      {:ok, %$Object{}}

      iex> create_$object(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_$object(map) :: {:ok, $Object.t} | {:error, Ecto.Changeset.t}
  def create_$object(attrs) do
    %$Object{}
    |> $Object.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a $object.

  ## Examples

      iex> update_$object($object, %{field: new_value})
      {:ok, %$Object{}}

      iex> update_$object($object, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_$object($Object.t, map) :: {:ok, $Object.t} | {:error, Ecto.Changeset.t}
  def update_$object(%$Object{} = $object, attrs) do
    $object
    |> $Object.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a $object.

  ## Examples

      iex> delete_$object($object)
      {:ok, %$Object{}}

      iex> delete_$object($object)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_$object($Object.t) :: {:ok, $Object.t} | {:error, Ecto.Changeset.t}
  def delete_$object(%$Object{} = $object) do
    Repo.delete($object)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking $object changes.

  ## Examples

      iex> change_$object($object)
      %Ecto.Changeset{data: %$Object{}}

  """
  @spec change_$object($Object.t, map) :: Ecto.Changeset.t
  def change_$object(%$Object{} = $object, attrs \\ %{}) do
    $Object.changeset($object, attrs)
  end
end
