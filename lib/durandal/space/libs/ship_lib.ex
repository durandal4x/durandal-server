defmodule Durandal.Space.ShipLib do
  @moduledoc """
  Library of ship related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Space.{Ship, ShipQueries}

  @spec topic(Durandal.ship_id()) :: String.t()
  def topic(ship_id), do: "Durandal.Space.Ship:#{ship_id}"

  @doc """
  Returns the list of ships.

  ## Examples

      iex> list_ships()
      [%Ship{}, ...]

  """
  @spec list_ships(Durandal.query_args()) :: [Ship.t()]
  def list_ships(query_args) do
    query_args
    |> ShipQueries.ship_query()
    |> Repo.all()
  end

  @doc """
  Gets a single ship.

  Raises `Ecto.NoResultsError` if the Ship does not exist.

  ## Examples

      iex> get_ship!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %Ship{}

      iex> get_ship!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_ship!(Ship.id(), Durandal.query_args()) :: Ship.t()
  def get_ship!(ship_id, query_args \\ []) do
    (query_args ++ [id: ship_id])
    |> ShipQueries.ship_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single ship.

  Returns nil if the Ship does not exist.

  ## Examples

      iex> get_ship("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %Ship{}

      iex> get_ship("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_ship(Ship.id(), Durandal.query_args()) :: Ship.t() | nil
  def get_ship(ship_id, query_args \\ []) do
    (query_args ++ [id: ship_id])
    |> ShipQueries.ship_query()
    |> Repo.one()
  end

  @doc """
  Gets a single ship complete with relevant preloads in place.

  Returns nil if the Ship does not exist.

  ## Examples

      iex> get_ship("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %Ship{}

      iex> get_ship("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_extended_ship(Ship.id()) :: Ship.t() | nil
  def get_extended_ship(ship_id) do
    get_ship(ship_id, preload: [:type, :orbiting, :docked_with])
  end

  @doc """
  Creates a ship.

  ## Examples

      iex> create_ship(%{field: value})
      {:ok, %Ship{}}

      iex> create_ship(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_ship(map) :: {:ok, Ship.t()} | {:error, Ecto.Changeset.t()}
  def create_ship(attrs) do
    %Ship{}
    |> Ship.changeset(attrs)
    |> Repo.insert()
    |> Durandal.broadcast_on_ok(&topic/1, :ship, %{event: :created_ship})
    |> Durandal.broadcast_on_ok({&Durandal.Player.team_topic/1, :team_id}, :ship, %{
      event: :created_ship
    })
    |> Durandal.broadcast_on_ok({&Durandal.Space.system_topic/1, :system_id}, :ship, %{
      event: :created_ship
    })
  end

  @doc """
  Updates a ship.

  ## Examples

      iex> update_ship(ship, %{field: new_value})
      {:ok, %Ship{}}

      iex> update_ship(ship, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_ship(Ship.t(), map) :: {:ok, Ship.t()} | {:error, Ecto.Changeset.t()}
  def update_ship(%Ship{} = ship, attrs) do
    ship
    |> Ship.changeset(attrs)
    |> Repo.update()
    |> Durandal.broadcast_on_ok(&topic/1, :ship, %{event: :updated_ship})
    |> Durandal.broadcast_on_ok({&Durandal.Player.team_topic/1, :team_id}, :ship, %{
      event: :updated_ship
    })
    |> Durandal.broadcast_on_ok({&Durandal.Space.system_topic/1, :system_id}, :ship, %{
      event: :updated_ship
    })
  end

  @doc """
  Deletes a ship.

  ## Examples

      iex> delete_ship(ship)
      {:ok, %Ship{}}

      iex> delete_ship(ship)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_ship(Ship.t()) :: {:ok, Ship.t()} | {:error, Ecto.Changeset.t()}
  def delete_ship(%Ship{} = ship) do
    Repo.delete(ship)
    |> Durandal.broadcast_on_ok(&topic/1, :ship, %{event: :deleted_ship})
    |> Durandal.broadcast_on_ok({&Durandal.Player.team_topic/1, :team_id}, :ship, %{
      event: :deleted_ship
    })
    |> Durandal.broadcast_on_ok({&Durandal.Space.system_topic/1, :system_id}, :ship, %{
      event: :deleted_ship
    })
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ship changes.

  ## Examples

      iex> change_ship(ship)
      %Ecto.Changeset{data: %Ship{}}

  """
  @spec change_ship(Ship.t(), map) :: Ecto.Changeset.t()
  def change_ship(%Ship{} = ship, attrs \\ %{}) do
    Ship.changeset(ship, attrs)
  end
end
