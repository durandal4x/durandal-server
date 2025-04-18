defmodule Durandal.Space.ShipTransferLib do
  @moduledoc """
  Library of ship_transfer related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Space.{ShipTransfer, ShipTransferQueries}

  @spec topic(Durandal.object_id()) :: String.t()
  def topic(ship_transfer_id), do: "Durandal.Space.ShipTransfer:#{ship_transfer_id}"

  @doc """
  Returns the list of ship_transfers.

  ## Examples

      iex> list_ship_transfers()
      [%ShipTransfer{}, ...]

  """
  @spec list_ship_transfers(Durandal.query_args()) :: [ShipTransfer.t()]
  def list_ship_transfers(query_args) do
    query_args
    |> ShipTransferQueries.ship_transfer_query()
    |> Repo.all()
  end

  @doc """
  Gets a single ship_transfer.

  Raises `Ecto.NoResultsError` if the ShipTransfer does not exist.

  ## Examples

      iex> get_ship_transfer!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %ShipTransfer{}

      iex> get_ship_transfer!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_ship_transfer!(ShipTransfer.id(), Durandal.query_args()) :: ShipTransfer.t()
  def get_ship_transfer!(ship_transfer_id, query_args \\ []) do
    (query_args ++ [id: ship_transfer_id])
    |> ShipTransferQueries.ship_transfer_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single ship_transfer.

  Returns nil if the ShipTransfer does not exist.

  ## Examples

      iex> get_ship_transfer("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %ShipTransfer{}

      iex> get_ship_transfer("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_ship_transfer(ShipTransfer.id(), Durandal.query_args()) :: ShipTransfer.t() | nil
  def get_ship_transfer(ship_transfer_id, query_args \\ []) do
    (query_args ++ [id: ship_transfer_id])
    |> ShipTransferQueries.ship_transfer_query()
    |> Repo.one()
  end

  @doc """
  Creates a ship_transfer.

  ## Examples

      iex> create_ship_transfer(%{field: value})
      {:ok, %ShipTransfer{}}

      iex> create_ship_transfer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_ship_transfer(map) :: {:ok, ShipTransfer.t()} | {:error, Ecto.Changeset.t()}
  def create_ship_transfer(attrs) do
    %ShipTransfer{}
    |> ShipTransfer.changeset(attrs)
    |> Repo.insert()
    |> Durandal.broadcast_on_ok(&topic/1, :object, %{event: :created_object})
  end

  @doc """
  Updates a ship_transfer.

  ## Examples

      iex> update_ship_transfer(ship_transfer, %{field: new_value})
      {:ok, %ShipTransfer{}}

      iex> update_ship_transfer(ship_transfer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_ship_transfer(ShipTransfer.t(), map) ::
          {:ok, ShipTransfer.t()} | {:error, Ecto.Changeset.t()}
  def update_ship_transfer(%ShipTransfer{} = ship_transfer, attrs) do
    ship_transfer
    |> ShipTransfer.changeset(attrs)
    |> Repo.update()
    |> Durandal.broadcast_on_ok(&topic/1, :object, %{event: :updated_object})
  end

  @doc """
  Deletes a ship_transfer.

  ## Examples

      iex> delete_ship_transfer(ship_transfer)
      {:ok, %ShipTransfer{}}

      iex> delete_ship_transfer(ship_transfer)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_ship_transfer(ShipTransfer.t()) ::
          {:ok, ShipTransfer.t()} | {:error, Ecto.Changeset.t()}
  def delete_ship_transfer(%ShipTransfer{} = ship_transfer) do
    Repo.delete(ship_transfer)
    |> Durandal.broadcast_on_ok(&topic/1, :object, %{event: :deleted_object})
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ship_transfer changes.

  ## Examples

      iex> change_ship_transfer(ship_transfer)
      %Ecto.Changeset{data: %ShipTransfer{}}

  """
  @spec change_ship_transfer(ShipTransfer.t(), map) :: Ecto.Changeset.t()
  def change_ship_transfer(%ShipTransfer{} = ship_transfer, attrs \\ %{}) do
    ShipTransfer.changeset(ship_transfer, attrs)
  end
end
