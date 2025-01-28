defmodule Durandal.Space.ColonyModuleLib do
  @moduledoc """
  Library of colony_module related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Space.{ColonyModule, ColonyModuleQueries}

  @doc """
  Returns the list of colony_modules.

  ## Examples

      iex> list_colony_modules()
      [%ColonyModule{}, ...]

  """
  @spec list_colony_modules(Durandal.query_args()) :: [ColonyModule.t()]
  def list_colony_modules(query_args) do
    query_args
    |> ColonyModuleQueries.colony_module_query()
    |> Repo.all()
  end

  @doc """
  Gets a single colony_module.

  Raises `Ecto.NoResultsError` if the ColonyModule does not exist.

  ## Examples

      iex> get_colony_module!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %ColonyModule{}

      iex> get_colony_module!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_colony_module!(ColonyModule.id(), Durandal.query_args()) :: ColonyModule.t()
  def get_colony_module!(colony_module_id, query_args \\ []) do
    (query_args ++ [id: colony_module_id])
    |> ColonyModuleQueries.colony_module_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single colony_module.

  Returns nil if the ColonyModule does not exist.

  ## Examples

      iex> get_colony_module("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %ColonyModule{}

      iex> get_colony_module("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_colony_module(ColonyModule.id(), Durandal.query_args()) :: ColonyModule.t() | nil
  def get_colony_module(colony_module_id, query_args \\ []) do
    (query_args ++ [id: colony_module_id])
    |> ColonyModuleQueries.colony_module_query()
    |> Repo.one()
  end

  @doc """
  Creates a colony_module.

  ## Examples

      iex> create_colony_module(%{field: value})
      {:ok, %ColonyModule{}}

      iex> create_colony_module(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_colony_module(map) :: {:ok, ColonyModule.t()} | {:error, Ecto.Changeset.t()}
  def create_colony_module(attrs) do
    %ColonyModule{}
    |> ColonyModule.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a colony_module.

  ## Examples

      iex> update_colony_module(colony_module, %{field: new_value})
      {:ok, %ColonyModule{}}

      iex> update_colony_module(colony_module, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_colony_module(ColonyModule.t(), map) ::
          {:ok, ColonyModule.t()} | {:error, Ecto.Changeset.t()}
  def update_colony_module(%ColonyModule{} = colony_module, attrs) do
    colony_module
    |> ColonyModule.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a colony_module.

  ## Examples

      iex> delete_colony_module(colony_module)
      {:ok, %ColonyModule{}}

      iex> delete_colony_module(colony_module)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_colony_module(ColonyModule.t()) ::
          {:ok, ColonyModule.t()} | {:error, Ecto.Changeset.t()}
  def delete_colony_module(%ColonyModule{} = colony_module) do
    Repo.delete(colony_module)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking colony_module changes.

  ## Examples

      iex> change_colony_module(colony_module)
      %Ecto.Changeset{data: %ColonyModule{}}

  """
  @spec change_colony_module(ColonyModule.t(), map) :: Ecto.Changeset.t()
  def change_colony_module(%ColonyModule{} = colony_module, attrs \\ %{}) do
    ColonyModule.changeset(colony_module, attrs)
  end
end
