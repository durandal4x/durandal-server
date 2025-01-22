defmodule Durandal.Space.ColonyLib do
  @moduledoc """
  Library of colony related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Space.{Colony, ColonyQueries}

  @doc """
  Returns the list of colonies.

  ## Examples

      iex> list_colonies()
      [%Colony{}, ...]

  """
  @spec list_colonies(Durandal.query_args()) :: [Colony.t()]
  def list_colonies(query_args) do
    query_args
    |> ColonyQueries.colony_query()
    |> Repo.all()
  end

  @doc """
  Gets a single colony.

  Raises `Ecto.NoResultsError` if the Colony does not exist.

  ## Examples

      iex> get_colony!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %Colony{}

      iex> get_colony!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_colony!(Colony.id(), Durandal.query_args()) :: Colony.t()
  def get_colony!(colony_id, query_args \\ []) do
    (query_args ++ [id: colony_id])
    |> ColonyQueries.colony_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single colony.

  Returns nil if the Colony does not exist.

  ## Examples

      iex> get_colony("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %Colony{}

      iex> get_colony("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_colony(Colony.id(), Durandal.query_args()) :: Colony.t() | nil
  def get_colony(colony_id, query_args \\ []) do
    (query_args ++ [id: colony_id])
    |> ColonyQueries.colony_query()
    |> Repo.one()
  end

  @doc """
  Creates a colony.

  ## Examples

      iex> create_colony(%{field: value})
      {:ok, %Colony{}}

      iex> create_colony(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_colony(map) :: {:ok, Colony.t()} | {:error, Ecto.Changeset.t()}
  def create_colony(attrs) do
    %Colony{}
    |> Colony.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a colony.

  ## Examples

      iex> update_colony(colony, %{field: new_value})
      {:ok, %Colony{}}

      iex> update_colony(colony, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_colony(Colony.t(), map) :: {:ok, Colony.t()} | {:error, Ecto.Changeset.t()}
  def update_colony(%Colony{} = colony, attrs) do
    colony
    |> Colony.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a colony.

  ## Examples

      iex> delete_colony(colony)
      {:ok, %Colony{}}

      iex> delete_colony(colony)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_colony(Colony.t()) :: {:ok, Colony.t()} | {:error, Ecto.Changeset.t()}
  def delete_colony(%Colony{} = colony) do
    Repo.delete(colony)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking colony changes.

  ## Examples

      iex> change_colony(colony)
      %Ecto.Changeset{data: %Colony{}}

  """
  @spec change_colony(Colony.t(), map) :: Ecto.Changeset.t()
  def change_colony(%Colony{} = colony, attrs \\ %{}) do
    Colony.changeset(colony, attrs)
  end
end
