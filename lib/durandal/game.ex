defmodule Durandal.Game do
  # Universes
  alias Durandal.Game.{Universe, UniverseLib, UniverseQueries}

  @doc false
  @spec universe_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate universe_query(args), to: UniverseQueries

  @doc section: :universe
  @spec list_universes(Durandal.query_args()) :: [Universe.t()]
  defdelegate list_universes(args), to: UniverseLib

  @doc section: :universe
  @spec get_universe!(Universe.id(), Durandal.query_args()) :: Universe.t()
  defdelegate get_universe!(universe_id, query_args \\ []), to: UniverseLib

  @doc section: :universe
  @spec get_universe(Universe.id(), Durandal.query_args()) :: Universe.t() | nil
  defdelegate get_universe(universe_id, query_args \\ []), to: UniverseLib

  @doc section: :universe
  @spec create_universe(map) :: {:ok, Universe.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_universe(attrs), to: UniverseLib

  @doc section: :universe
  @spec update_universe(Universe, map) :: {:ok, Universe.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_universe(universe, attrs), to: UniverseLib

  @doc section: :universe
  @spec delete_universe(Universe.t()) :: {:ok, Universe.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_universe(universe), to: UniverseLib

  @doc section: :universe
  @spec change_universe(Universe.t(), map) :: Ecto.Changeset.t()
  defdelegate change_universe(universe, attrs \\ %{}), to: UniverseLib
end
