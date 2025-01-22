defmodule Durandal.Types.ColonyModuleTypeLib do
  @moduledoc """
  Library of colony_module_types related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Types.{ColonyModuleType, ColonyModuleTypeQueries}

  @doc """
  Returns the list of colony_module_types.

  ## Examples

      iex> list_colony_module_types()
      [%ColonyModuleType{}, ...]

  """
  @spec list_colony_module_types(Durandal.query_args()) :: [ColonyModuleType.t()]
  def list_colony_module_types(query_args) do
    query_args
    |> ColonyModuleTypeQueries.colony_module_types_query()
    |> Repo.all()
  end

  @doc """
  Gets a single colony_module_types.

  Raises `Ecto.NoResultsError` if the ColonyModuleType does not exist.

  ## Examples

      iex> get_colony_module_types!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %ColonyModuleType{}

      iex> get_colony_module_types!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_colony_module_types!(ColonyModuleType.id(), Durandal.query_args()) ::
          ColonyModuleType.t()
  def get_colony_module_types!(colony_module_types_id, query_args \\ []) do
    (query_args ++ [id: colony_module_types_id])
    |> ColonyModuleTypeQueries.colony_module_types_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single colony_module_types.

  Returns nil if the ColonyModuleType does not exist.

  ## Examples

      iex> get_colony_module_types("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %ColonyModuleType{}

      iex> get_colony_module_types("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_colony_module_types(ColonyModuleType.id(), Durandal.query_args()) ::
          ColonyModuleType.t() | nil
  def get_colony_module_types(colony_module_types_id, query_args \\ []) do
    (query_args ++ [id: colony_module_types_id])
    |> ColonyModuleTypeQueries.colony_module_types_query()
    |> Repo.one()
  end

  @doc """
  Creates a colony_module_types.

  ## Examples

      iex> create_colony_module_types(%{field: value})
      {:ok, %ColonyModuleType{}}

      iex> create_colony_module_types(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_colony_module_types(map) ::
          {:ok, ColonyModuleType.t()} | {:error, Ecto.Changeset.t()}
  def create_colony_module_types(attrs) do
    %ColonyModuleType{}
    |> ColonyModuleType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a colony_module_types.

  ## Examples

      iex> update_colony_module_types(colony_module_types, %{field: new_value})
      {:ok, %ColonyModuleType{}}

      iex> update_colony_module_types(colony_module_types, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_colony_module_types(ColonyModuleType.t(), map) ::
          {:ok, ColonyModuleType.t()} | {:error, Ecto.Changeset.t()}
  def update_colony_module_types(%ColonyModuleType{} = colony_module_types, attrs) do
    colony_module_types
    |> ColonyModuleType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a colony_module_types.

  ## Examples

      iex> delete_colony_module_types(colony_module_types)
      {:ok, %ColonyModuleType{}}

      iex> delete_colony_module_types(colony_module_types)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_colony_module_types(ColonyModuleType.t()) ::
          {:ok, ColonyModuleType.t()} | {:error, Ecto.Changeset.t()}
  def delete_colony_module_types(%ColonyModuleType{} = colony_module_types) do
    Repo.delete(colony_module_types)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking colony_module_types changes.

  ## Examples

      iex> change_colony_module_types(colony_module_types)
      %Ecto.Changeset{data: %ColonyModuleType{}}

  """
  @spec change_colony_module_types(ColonyModuleType.t(), map) :: Ecto.Changeset.t()
  def change_colony_module_types(%ColonyModuleType{} = colony_module_types, attrs \\ %{}) do
    ColonyModuleType.changeset(colony_module_types, attrs)
  end
end
