defmodule Durandal.Space.StationTransferLib do
  @moduledoc """
  Library of station_transfer related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Space.{StationTransfer, StationTransferQueries}

  @spec topic(Durandal.object_id()) :: String.t()
  def topic(station_transfer_id), do: "Durandal.Space.StationTransfer:#{station_transfer_id}"

  @doc """
  Returns the list of station_transfers.

  ## Examples

      iex> list_station_transfers()
      [%StationTransfer{}, ...]

  """
  @spec list_station_transfers(Durandal.query_args()) :: [StationTransfer.t()]
  def list_station_transfers(query_args) do
    query_args
    |> StationTransferQueries.station_transfer_query()
    |> Repo.all()
  end

  @doc """
  Gets a single station_transfer.

  Raises `Ecto.NoResultsError` if the StationTransfer does not exist.

  ## Examples

      iex> get_station_transfer!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %StationTransfer{}

      iex> get_station_transfer!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_station_transfer!(StationTransfer.id(), Durandal.query_args()) :: StationTransfer.t()
  def get_station_transfer!(station_transfer_id, query_args \\ []) do
    (query_args ++ [id: station_transfer_id])
    |> StationTransferQueries.station_transfer_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single station_transfer.

  Returns nil if the StationTransfer does not exist.

  ## Examples

      iex> get_station_transfer("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %StationTransfer{}

      iex> get_station_transfer("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_station_transfer(StationTransfer.id(), Durandal.query_args()) ::
          StationTransfer.t() | nil
  def get_station_transfer(station_transfer_id, query_args \\ []) do
    (query_args ++ [id: station_transfer_id])
    |> StationTransferQueries.station_transfer_query()
    |> Repo.one()
  end

  @doc """
  Creates a station_transfer.

  ## Examples

      iex> create_station_transfer(%{field: value})
      {:ok, %StationTransfer{}}

      iex> create_station_transfer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_station_transfer(map) :: {:ok, StationTransfer.t()} | {:error, Ecto.Changeset.t()}
  def create_station_transfer(attrs) do
    %StationTransfer{}
    |> StationTransfer.changeset(attrs)
    |> Repo.insert()
    |> Durandal.broadcast_on_ok(&topic/1, :object, %{event: :created_object})
  end

  @doc """
  Updates a station_transfer.

  ## Examples

      iex> update_station_transfer(station_transfer, %{field: new_value})
      {:ok, %StationTransfer{}}

      iex> update_station_transfer(station_transfer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_station_transfer(StationTransfer.t(), map) ::
          {:ok, StationTransfer.t()} | {:error, Ecto.Changeset.t()}
  def update_station_transfer(%StationTransfer{} = station_transfer, attrs) do
    station_transfer
    |> StationTransfer.changeset(attrs)
    |> Repo.update()
    |> Durandal.broadcast_on_ok(&topic/1, :object, %{event: :updated_object})
  end

  @doc """
  Deletes a station_transfer.

  ## Examples

      iex> delete_station_transfer(station_transfer)
      {:ok, %StationTransfer{}}

      iex> delete_station_transfer(station_transfer)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_station_transfer(StationTransfer.t()) ::
          {:ok, StationTransfer.t()} | {:error, Ecto.Changeset.t()}
  def delete_station_transfer(%StationTransfer{} = station_transfer) do
    Repo.delete(station_transfer)
    |> Durandal.broadcast_on_ok(&topic/1, :object, %{event: :deleted_object})
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking station_transfer changes.

  ## Examples

      iex> change_station_transfer(station_transfer)
      %Ecto.Changeset{data: %StationTransfer{}}

  """
  @spec change_station_transfer(StationTransfer.t(), map) :: Ecto.Changeset.t()
  def change_station_transfer(%StationTransfer{} = station_transfer, attrs \\ %{}) do
    StationTransfer.changeset(station_transfer, attrs)
  end
end
