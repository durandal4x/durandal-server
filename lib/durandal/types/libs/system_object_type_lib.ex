defmodule Durandal.Types.SystemObjectTypeLib do
  @moduledoc """
  Library of system_object_type related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Types.{SystemObjectType, SystemObjectTypeQueries}

  @spec topic(Durandal.system_object_type_id()) :: String.t()
  def topic(system_object_type_id), do: "Durandal.Types.SystemObjectType:#{system_object_type_id}"

  @doc """
  Returns the list of system_object_types.

  ## Examples

      iex> list_system_object_types()
      [%SystemObjectType{}, ...]

  """
  @spec list_system_object_types(Durandal.query_args()) :: [SystemObjectType.t()]
  def list_system_object_types(query_args) do
    query_args
    |> SystemObjectTypeQueries.system_object_type_query()
    |> Repo.all()
  end

  @doc """
  Gets a single system_object_type.

  Raises `Ecto.NoResultsError` if the SystemObjectType does not exist.

  ## Examples

      iex> get_system_object_type!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %SystemObjectType{}

      iex> get_system_object_type!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_system_object_type!(SystemObjectType.id(), Durandal.query_args()) ::
          SystemObjectType.t()
  def get_system_object_type!(system_object_type_id, query_args \\ []) do
    (query_args ++ [id: system_object_type_id])
    |> SystemObjectTypeQueries.system_object_type_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single system_object_type.

  Returns nil if the SystemObjectType does not exist.

  ## Examples

      iex> get_system_object_type("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %SystemObjectType{}

      iex> get_system_object_type("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_system_object_type(SystemObjectType.id(), Durandal.query_args()) ::
          SystemObjectType.t() | nil
  def get_system_object_type(system_object_type_id, query_args \\ []) do
    (query_args ++ [id: system_object_type_id])
    |> SystemObjectTypeQueries.system_object_type_query()
    |> Repo.one()
  end

  @doc """
  Creates a system_object_type.

  ## Examples

      iex> create_system_object_type(%{field: value})
      {:ok, %SystemObjectType{}}

      iex> create_system_object_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_system_object_type(map) ::
          {:ok, SystemObjectType.t()} | {:error, Ecto.Changeset.t()}
  def create_system_object_type(attrs) do
    %SystemObjectType{}
    |> SystemObjectType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a system_object_type.

  ## Examples

      iex> update_system_object_type(system_object_type, %{field: new_value})
      {:ok, %SystemObjectType{}}

      iex> update_system_object_type(system_object_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_system_object_type(SystemObjectType.t(), map) ::
          {:ok, SystemObjectType.t()} | {:error, Ecto.Changeset.t()}
  def update_system_object_type(%SystemObjectType{} = system_object_type, attrs) do
    system_object_type
    |> SystemObjectType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a system_object_type.

  ## Examples

      iex> delete_system_object_type(system_object_type)
      {:ok, %SystemObjectType{}}

      iex> delete_system_object_type(system_object_type)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_system_object_type(SystemObjectType.t()) ::
          {:ok, SystemObjectType.t()} | {:error, Ecto.Changeset.t()}
  def delete_system_object_type(%SystemObjectType{} = system_object_type) do
    Repo.delete(system_object_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking system_object_type changes.

  ## Examples

      iex> change_system_object_type(system_object_type)
      %Ecto.Changeset{data: %SystemObjectType{}}

  """
  @spec change_system_object_type(SystemObjectType.t(), map) :: Ecto.Changeset.t()
  def change_system_object_type(%SystemObjectType{} = system_object_type, attrs \\ %{}) do
    SystemObjectType.changeset(system_object_type, attrs)
  end
end
