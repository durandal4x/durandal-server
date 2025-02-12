defmodule Durandal.Types.ShipTypeLib do
  @moduledoc """
  Library of ship_type related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Types.{ShipType, ShipTypeQueries}

  @doc """
  Returns the list of ship_types.

  ## Examples

      iex> list_ship_types()
      [%ShipType{}, ...]

  """
  @spec list_ship_types(Durandal.query_args()) :: [ShipType.t()]
  def list_ship_types(query_args) do
    query_args
    |> ShipTypeQueries.ship_type_query()
    |> Repo.all()
  end

  @doc """
  Gets a single ship_type.

  Raises `Ecto.NoResultsError` if the ShipType does not exist.

  ## Examples

      iex> get_ship_type!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %ShipType{}

      iex> get_ship_type!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_ship_type!(ShipType.id(), Durandal.query_args()) :: ShipType.t()
  def get_ship_type!(ship_type_id, query_args \\ []) do
    (query_args ++ [id: ship_type_id])
    |> ShipTypeQueries.ship_type_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single ship_type.

  Returns nil if the ShipType does not exist.

  ## Examples

      iex> get_ship_type("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %ShipType{}

      iex> get_ship_type("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_ship_type(ShipType.id(), Durandal.query_args()) :: ShipType.t() | nil
  def get_ship_type(ship_type_id, query_args \\ []) do
    (query_args ++ [id: ship_type_id])
    |> ShipTypeQueries.ship_type_query()
    |> Repo.one()
  end

  @doc """
  Creates a ship_type.

  ## Examples

      iex> create_ship_type(%{field: value})
      {:ok, %ShipType{}}

      iex> create_ship_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_ship_type(map) :: {:ok, ShipType.t()} | {:error, Ecto.Changeset.t()}
  def create_ship_type(attrs) do
    %ShipType{}
    |> ShipType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ship_type.

  ## Examples

      iex> update_ship_type(ship_type, %{field: new_value})
      {:ok, %ShipType{}}

      iex> update_ship_type(ship_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_ship_type(ShipType.t(), map) :: {:ok, ShipType.t()} | {:error, Ecto.Changeset.t()}
  def update_ship_type(%ShipType{} = ship_type, attrs) do
    ship_type
    |> ShipType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ship_type.

  ## Examples

      iex> delete_ship_type(ship_type)
      {:ok, %ShipType{}}

      iex> delete_ship_type(ship_type)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_ship_type(ShipType.t()) :: {:ok, ShipType.t()} | {:error, Ecto.Changeset.t()}
  def delete_ship_type(%ShipType{} = ship_type) do
    Repo.delete(ship_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ship_type changes.

  ## Examples

      iex> change_ship_type(ship_type)
      %Ecto.Changeset{data: %ShipType{}}

  """
  @spec change_ship_type(ShipType.t(), map) :: Ecto.Changeset.t()
  def change_ship_type(%ShipType{} = ship_type, attrs \\ %{}) do
    ShipType.changeset(ship_type, attrs)
  end
end
