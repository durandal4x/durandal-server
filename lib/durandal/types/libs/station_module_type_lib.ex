defmodule Durandal.Types.StationModuleTypeLib do
  @moduledoc """
  Library of station_module_type related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Types.{StationModuleType, StationModuleTypeQueries}

  @doc """
  Returns the list of station_module_types.

  ## Examples

      iex> list_station_module_types()
      [%StationModuleType{}, ...]

  """
  @spec list_station_module_types(Durandal.query_args()) :: [StationModuleType.t()]
  def list_station_module_types(query_args) do
    query_args
    |> StationModuleTypeQueries.station_module_type_query()
    |> Repo.all()
  end

  @doc """
  Gets a single station_module_type.

  Raises `Ecto.NoResultsError` if the StationModuleType does not exist.

  ## Examples

      iex> get_station_module_type!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %StationModuleType{}

      iex> get_station_module_type!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_station_module_type!(StationModuleType.id(), Durandal.query_args()) ::
          StationModuleType.t()
  def get_station_module_type!(station_module_type_id, query_args \\ []) do
    (query_args ++ [id: station_module_type_id])
    |> StationModuleTypeQueries.station_module_type_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single station_module_type.

  Returns nil if the StationModuleType does not exist.

  ## Examples

      iex> get_station_module_type("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %StationModuleType{}

      iex> get_station_module_type("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_station_module_type(StationModuleType.id(), Durandal.query_args()) ::
          StationModuleType.t() | nil
  def get_station_module_type(station_module_type_id, query_args \\ []) do
    (query_args ++ [id: station_module_type_id])
    |> StationModuleTypeQueries.station_module_type_query()
    |> Repo.one()
  end

  @doc """
  Creates a station_module_type.

  ## Examples

      iex> create_station_module_type(%{field: value})
      {:ok, %StationModuleType{}}

      iex> create_station_module_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_station_module_type(map) ::
          {:ok, StationModuleType.t()} | {:error, Ecto.Changeset.t()}
  def create_station_module_type(attrs) do
    %StationModuleType{}
    |> StationModuleType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a station_module_type.

  ## Examples

      iex> update_station_module_type(station_module_type, %{field: new_value})
      {:ok, %StationModuleType{}}

      iex> update_station_module_type(station_module_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_station_module_type(StationModuleType.t(), map) ::
          {:ok, StationModuleType.t()} | {:error, Ecto.Changeset.t()}
  def update_station_module_type(%StationModuleType{} = station_module_type, attrs) do
    station_module_type
    |> StationModuleType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a station_module_type.

  ## Examples

      iex> delete_station_module_type(station_module_type)
      {:ok, %StationModuleType{}}

      iex> delete_station_module_type(station_module_type)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_station_module_type(StationModuleType.t()) ::
          {:ok, StationModuleType.t()} | {:error, Ecto.Changeset.t()}
  def delete_station_module_type(%StationModuleType{} = station_module_type) do
    Repo.delete(station_module_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking station_module_type changes.

  ## Examples

      iex> change_station_module_type(station_module_type)
      %Ecto.Changeset{data: %StationModuleType{}}

  """
  @spec change_station_module_type(StationModuleType.t(), map) :: Ecto.Changeset.t()
  def change_station_module_type(%StationModuleType{} = station_module_type, attrs \\ %{}) do
    StationModuleType.changeset(station_module_type, attrs)
  end
end
