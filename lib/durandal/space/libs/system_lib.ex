defmodule Durandal.Space.SystemLib do
  @moduledoc """
  Library of system related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Space.{System, SystemQueries}

  @doc """
  Returns the list of systems.

  ## Examples

      iex> list_systems()
      [%System{}, ...]

  """
  @spec list_systems(Durandal.query_args()) :: [System.t()]
  def list_systems(query_args) do
    query_args
    |> SystemQueries.system_query()
    |> Repo.all()
  end

  @doc """
  Gets a single system.

  Raises `Ecto.NoResultsError` if the System does not exist.

  ## Examples

      iex> get_system!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %System{}

      iex> get_system!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_system!(System.id(), Durandal.query_args()) :: System.t()
  def get_system!(system_id, query_args \\ []) do
    (query_args ++ [id: system_id])
    |> SystemQueries.system_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single system.

  Returns nil if the System does not exist.

  ## Examples

      iex> get_system("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %System{}

      iex> get_system("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_system(System.id(), Durandal.query_args()) :: System.t() | nil
  def get_system(system_id, query_args \\ []) do
    (query_args ++ [id: system_id])
    |> SystemQueries.system_query()
    |> Repo.one()
  end

  @doc """
  Creates a system.

  ## Examples

      iex> create_system(%{field: value})
      {:ok, %System{}}

      iex> create_system(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_system(map) :: {:ok, System.t()} | {:error, Ecto.Changeset.t()}
  def create_system(attrs) do
    %System{}
    |> System.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a system.

  ## Examples

      iex> update_system(system, %{field: new_value})
      {:ok, %System{}}

      iex> update_system(system, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_system(System.t(), map) :: {:ok, System.t()} | {:error, Ecto.Changeset.t()}
  def update_system(%System{} = system, attrs) do
    system
    |> System.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a system.

  ## Examples

      iex> delete_system(system)
      {:ok, %System{}}

      iex> delete_system(system)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_system(System.t()) :: {:ok, System.t()} | {:error, Ecto.Changeset.t()}
  def delete_system(%System{} = system) do
    Repo.delete(system)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking system changes.

  ## Examples

      iex> change_system(system)
      %Ecto.Changeset{data: %System{}}

  """
  @spec change_system(System.t(), map) :: Ecto.Changeset.t()
  def change_system(%System{} = system, attrs \\ %{}) do
    System.changeset(system, attrs)
  end
end
