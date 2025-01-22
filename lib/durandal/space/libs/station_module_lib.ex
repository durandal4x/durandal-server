defmodule Durandal.Space.StationModuleLib do
  @moduledoc """
  Library of station_module related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Space.{StationModule, StationModuleQueries}

  @doc """
  Returns the list of station_modules.

  ## Examples

      iex> list_station_modules()
      [%StationModule{}, ...]

  """
  @spec list_station_modules(Durandal.query_args()) :: [StationModule.t()]
  def list_station_modules(query_args) do
    query_args
    |> StationModuleQueries.station_module_query()
    |> Repo.all()
  end

  @doc """
  Gets a single station_module.

  Raises `Ecto.NoResultsError` if the StationModule does not exist.

  ## Examples

      iex> get_station_module!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %StationModule{}

      iex> get_station_module!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_station_module!(StationModule.id(), Durandal.query_args()) :: StationModule.t()
  def get_station_module!(station_module_id, query_args \\ []) do
    (query_args ++ [id: station_module_id])
    |> StationModuleQueries.station_module_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single station_module.

  Returns nil if the StationModule does not exist.

  ## Examples

      iex> get_station_module("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %StationModule{}

      iex> get_station_module("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_station_module(StationModule.id(), Durandal.query_args()) :: StationModule.t() | nil
  def get_station_module(station_module_id, query_args \\ []) do
    (query_args ++ [id: station_module_id])
    |> StationModuleQueries.station_module_query()
    |> Repo.one()
  end

  @doc """
  Creates a station_module.

  ## Examples

      iex> create_station_module(%{field: value})
      {:ok, %StationModule{}}

      iex> create_station_module(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_station_module(map) :: {:ok, StationModule.t()} | {:error, Ecto.Changeset.t()}
  def create_station_module(attrs) do
    %StationModule{}
    |> StationModule.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a station_module.

  ## Examples

      iex> update_station_module(station_module, %{field: new_value})
      {:ok, %StationModule{}}

      iex> update_station_module(station_module, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_station_module(StationModule.t(), map) ::
          {:ok, StationModule.t()} | {:error, Ecto.Changeset.t()}
  def update_station_module(%StationModule{} = station_module, attrs) do
    station_module
    |> StationModule.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a station_module.

  ## Examples

      iex> delete_station_module(station_module)
      {:ok, %StationModule{}}

      iex> delete_station_module(station_module)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_station_module(StationModule.t()) ::
          {:ok, StationModule.t()} | {:error, Ecto.Changeset.t()}
  def delete_station_module(%StationModule{} = station_module) do
    Repo.delete(station_module)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking station_module changes.

  ## Examples

      iex> change_station_module(station_module)
      %Ecto.Changeset{data: %StationModule{}}

  """
  @spec change_station_module(StationModule.t(), map) :: Ecto.Changeset.t()
  def change_station_module(%StationModule{} = station_module, attrs \\ %{}) do
    StationModule.changeset(station_module, attrs)
  end
end
