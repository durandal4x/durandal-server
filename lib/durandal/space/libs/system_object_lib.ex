defmodule Durandal.Space.SystemObjectLib do
  @moduledoc """
  Library of system_object related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Space.{SystemObject, SystemObjectQueries}

  @spec topic(Durandal.system_object_id()) :: String.t()
  def topic(system_object_id), do: "Durandal.Space.SystemObject:#{system_object_id}"

  @doc """
  Returns the list of system_objects.

  ## Examples

      iex> list_system_objects()
      [%SystemObject{}, ...]

  """
  @spec list_system_objects(Durandal.query_args()) :: [SystemObject.t()]
  def list_system_objects(query_args) do
    query_args
    |> SystemObjectQueries.system_object_query()
    |> Repo.all()
  end

  @doc """
  Gets a single system_object.

  Raises `Ecto.NoResultsError` if the SystemObject does not exist.

  ## Examples

      iex> get_system_object!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %SystemObject{}

      iex> get_system_object!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_system_object!(SystemObject.id(), Durandal.query_args()) :: SystemObject.t()
  def get_system_object!(system_object_id, query_args \\ []) do
    (query_args ++ [id: system_object_id])
    |> SystemObjectQueries.system_object_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single system_object.

  Returns nil if the SystemObject does not exist.

  ## Examples

      iex> get_system_object("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %SystemObject{}

      iex> get_system_object("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_system_object(SystemObject.id(), Durandal.query_args()) :: SystemObject.t() | nil
  def get_system_object(system_object_id, query_args \\ []) do
    (query_args ++ [id: system_object_id])
    |> SystemObjectQueries.system_object_query()
    |> Repo.one()
  end

  @doc """
  Creates a system_object.

  ## Examples

      iex> create_system_object(%{field: value})
      {:ok, %SystemObject{}}

      iex> create_system_object(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_system_object(map) :: {:ok, SystemObject.t()} | {:error, Ecto.Changeset.t()}
  def create_system_object(attrs) do
    %SystemObject{}
    |> SystemObject.changeset(attrs)
    |> Repo.insert()
    |> Durandal.broadcast_on_ok(&topic/1, :system_object, %{event: :created_system_object})
    |> Durandal.broadcast_on_ok({&Durandal.Space.system_topic/1, :system_id}, :system_object, %{
      event: :created_system_object
    })
  end

  @doc """
  Updates a system_object.

  ## Examples

      iex> update_system_object(system_object, %{field: new_value})
      {:ok, %SystemObject{}}

      iex> update_system_object(system_object, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_system_object(SystemObject.t(), map) ::
          {:ok, SystemObject.t()} | {:error, Ecto.Changeset.t()}
  def update_system_object(%SystemObject{} = system_object, attrs) do
    system_object
    |> SystemObject.changeset(attrs)
    |> Repo.update()
    |> Durandal.broadcast_on_ok(&topic/1, :system_object, %{event: :updated_system_object})
    |> Durandal.broadcast_on_ok({&Durandal.Space.system_topic/1, :system_id}, :system_object, %{
      event: :updated_system_object
    })
  end

  @doc """
  Deletes a system_object.

  ## Examples

      iex> delete_system_object(system_object)
      {:ok, %SystemObject{}}

      iex> delete_system_object(system_object)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_system_object(SystemObject.t()) ::
          {:ok, SystemObject.t()} | {:error, Ecto.Changeset.t()}
  def delete_system_object(%SystemObject{} = system_object) do
    Repo.delete(system_object)
    |> Durandal.broadcast_on_ok(&topic/1, :system_object, %{event: :deleted_system_object})
    |> Durandal.broadcast_on_ok({&Durandal.Space.system_topic/1, :system_id}, :system_object, %{
      event: :deleted_system_object
    })
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking system_object changes.

  ## Examples

      iex> change_system_object(system_object)
      %Ecto.Changeset{data: %SystemObject{}}

  """
  @spec change_system_object(SystemObject.t(), map) :: Ecto.Changeset.t()
  def change_system_object(%SystemObject{} = system_object, attrs \\ %{}) do
    SystemObject.changeset(system_object, attrs)
  end
end
