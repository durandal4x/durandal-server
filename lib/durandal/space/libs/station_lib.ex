defmodule Durandal.Space.StationLib do
  @moduledoc """
  Library of station related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Space.{Station, StationQueries}

  @doc """
  Returns the list of stations.

  ## Examples

      iex> list_stations()
      [%Station{}, ...]

  """
  @spec list_stations(Durandal.query_args()) :: [Station.t()]
  def list_stations(query_args) do
    query_args
    |> StationQueries.station_query()
    |> Repo.all()
  end

  @doc """
  Gets a single station.

  Raises `Ecto.NoResultsError` if the Station does not exist.

  ## Examples

      iex> get_station!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %Station{}

      iex> get_station!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_station!(Station.id(), Durandal.query_args()) :: Station.t()
  def get_station!(station_id, query_args \\ []) do
    (query_args ++ [id: station_id])
    |> StationQueries.station_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single station.

  Returns nil if the Station does not exist.

  ## Examples

      iex> get_station("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %Station{}

      iex> get_station("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_station(Station.id(), Durandal.query_args()) :: Station.t() | nil
  def get_station(station_id, query_args \\ []) do
    (query_args ++ [id: station_id])
    |> StationQueries.station_query()
    |> Repo.one()
  end

  @doc """
  Creates a station.

  ## Examples

      iex> create_station(%{field: value})
      {:ok, %Station{}}

      iex> create_station(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_station(map) :: {:ok, Station.t()} | {:error, Ecto.Changeset.t()}
  def create_station(attrs) do
    %Station{}
    |> Station.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a station.

  ## Examples

      iex> update_station(station, %{field: new_value})
      {:ok, %Station{}}

      iex> update_station(station, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_station(Station.t(), map) :: {:ok, Station.t()} | {:error, Ecto.Changeset.t()}
  def update_station(%Station{} = station, attrs) do
    station
    |> Station.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a station.

  ## Examples

      iex> delete_station(station)
      {:ok, %Station{}}

      iex> delete_station(station)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_station(Station.t()) :: {:ok, Station.t()} | {:error, Ecto.Changeset.t()}
  def delete_station(%Station{} = station) do
    Repo.delete(station)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking station changes.

  ## Examples

      iex> change_station(station)
      %Ecto.Changeset{data: %Station{}}

  """
  @spec change_station(Station.t(), map) :: Ecto.Changeset.t()
  def change_station(%Station{} = station, attrs \\ %{}) do
    Station.changeset(station, attrs)
  end
end
