defmodule Durandal.$Context.Part1Part2Lib do
  @moduledoc """
  TODO: Library of part1_part2 related functions.
  """
  use DurandalMacros, :library
  alias Durandal.$Context.{Part1Part2, Part1Part2Queries}

  @doc """
  Returns the list of part1_part2s.

  ## Examples

      iex> list_part1_part2s()
      [%Part1Part2{}, ...]

  """
  @spec list_part1_part2s(Durandal.query_args()) :: [Part1Part2.t()]
  def list_part1_part2s(query_args) do
    query_args
    |> Part1Part2Queries.part1_part2_query()
    |> Repo.all()
  end

  @doc """
  Gets a single part1_part2.

  Raises `Ecto.NoResultsError` if the Part1Part2 does not exist.

  ## Examples

      iex> get_part1_part2!(123)
      %Part1Part2{}

      iex> get_part1_part2!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_part1_part2!(part1_id(), part2_id(), Durandal.query_args()) ::
          Part1Part2.t()
  def get_part1_part2!(part1_id, part2_id, query_args \\ []) do
    (query_args ++ [part1_id: part1_id, part2_id: part2_id])
    |> Part1Part2Queries.part1_part2_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single part1_part2.

  Returns nil if the Part1Part2 does not exist.

  ## Examples

      iex> get_part1_part2(123)
      %Part1Part2{}

      iex> get_part1_part2(456)
      nil

  """
  @spec get_part1_part2(part1_id(), part2_id(), Durandal.query_args()) ::
          Part1Part2.t() | nil
  def get_part1_part2(part1_id, part2_id, query_args \\ []) do
    (query_args ++ [part1_id: part1_id, part2_id: part2_id])
    |> Part1Part2Queries.part1_part2_query()
    |> Repo.one()
  end

  @doc """
  Creates a part1_part2.

  ## Examples

      iex> create_part1_part2(%{field: value})
      {:ok, %Part1Part2{}}

      iex> create_part1_part2(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_part1_part2(map) :: {:ok, Part1Part2.t()} | {:error, Ecto.Changeset.t()}
  def create_part1_part2(attrs) do
    %Part1Part2{}
    |> Part1Part2.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates many part1_part2s. Not unlike most other create functions this will raise an exception on failure and should not be caught using the normal case functions.

  Expects a map of values which can be turned into valid part1 part2s.

  ## Examples

      iex> create_many_part1_part2s([%{field: value}])
      {:ok, %Part1Part2{}}

      iex> create_many_part1_part2s([%{field: bad_value}])
      raise Postgrex.Error

  """
  @spec create_many_part1_part2s([map]) :: {:ok, map}
  def create_many_part1_part2s(attr_list) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Part1Part2, attr_list)
    |> Durandal.Repo.transaction()
  end

  @doc """
  Updates a part1_part2.

  ## Examples

      iex> update_part1_part2(part1_part2, %{field: new_value})
      {:ok, %Part1Part2{}}

      iex> update_part1_part2(part1_part2, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_part1_part2(Part1Part2.t(), map) ::
          {:ok, Part1Part2.t()} | {:error, Ecto.Changeset.t()}
  def update_part1_part2(%Part1Part2{} = part1_part2, attrs) do
    part1_part2
    |> Part1Part2.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a part1_part2.

  ## Examples

      iex> delete_part1_part2(part1_part2)
      {:ok, %Part1Part2{}}

      iex> delete_part1_part2(part1_part2)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_part1_part2(Part1Part2.t()) ::
          {:ok, Part1Part2.t()} | {:error, Ecto.Changeset.t()}
  def delete_part1_part2(%Part1Part2{} = part1_part2) do
    Repo.delete(part1_part2)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking part1_part2 changes.

  ## Examples

      iex> change_part1_part2(part1_part2)
      %Ecto.Changeset{data: %Part1Part2{}}

  """
  @spec change_part1_part2(Part1Part2.t(), map) :: Ecto.Changeset.t()
  def change_part1_part2(%Part1Part2{} = part1_part2, attrs \\ %{}) do
    Part1Part2.changeset(part1_part2, attrs)
  end
end
