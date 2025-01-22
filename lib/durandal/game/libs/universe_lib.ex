defmodule Durandal.Game.UniverseLib do
  @moduledoc """
  Library of universe related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Game.{Universe, UniverseQueries}

  @doc """
  Returns the list of universes.

  ## Examples

      iex> list_universes()
      [%Universe{}, ...]

  """
  @spec list_universes(Durandal.query_args()) :: [Universe.t()]
  def list_universes(query_args) do
    query_args
    |> UniverseQueries.universe_query()
    |> Repo.all()
  end

  @doc """
  Gets a single universe.

  Raises `Ecto.NoResultsError` if the Universe does not exist.

  ## Examples

      iex> get_universe!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %Universe{}

      iex> get_universe!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_universe!(Universe.id(), Durandal.query_args()) :: Universe.t()
  def get_universe!(universe_id, query_args \\ []) do
    (query_args ++ [id: universe_id])
    |> UniverseQueries.universe_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single universe.

  Returns nil if the Universe does not exist.

  ## Examples

      iex> get_universe("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %Universe{}

      iex> get_universe("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_universe(Universe.id(), Durandal.query_args()) :: Universe.t() | nil
  def get_universe(universe_id, query_args \\ []) do
    (query_args ++ [id: universe_id])
    |> UniverseQueries.universe_query()
    |> Repo.one()
  end

  @doc """
  Creates a universe.

  ## Examples

      iex> create_universe(%{field: value})
      {:ok, %Universe{}}

      iex> create_universe(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_universe(map) :: {:ok, Universe.t()} | {:error, Ecto.Changeset.t()}
  def create_universe(attrs) do
    %Universe{}
    |> Universe.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a universe.

  ## Examples

      iex> update_universe(universe, %{field: new_value})
      {:ok, %Universe{}}

      iex> update_universe(universe, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_universe(Universe.t(), map) :: {:ok, Universe.t()} | {:error, Ecto.Changeset.t()}
  def update_universe(%Universe{} = universe, attrs) do
    universe
    |> Universe.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a universe.

  ## Examples

      iex> delete_universe(universe)
      {:ok, %Universe{}}

      iex> delete_universe(universe)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_universe(Universe.t()) :: {:ok, Universe.t()} | {:error, Ecto.Changeset.t()}
  def delete_universe(%Universe{} = universe) do
    Repo.delete(universe)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking universe changes.

  ## Examples

      iex> change_universe(universe)
      %Ecto.Changeset{data: %Universe{}}

  """
  @spec change_universe(Universe.t(), map) :: Ecto.Changeset.t()
  def change_universe(%Universe{} = universe, attrs \\ %{}) do
    Universe.changeset(universe, attrs)
  end
end
