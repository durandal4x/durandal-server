defmodule Durandal.Player.TeamQueries do
  @moduledoc false
  use DurandalMacros, :queries
  alias Durandal.Player.Team
  require Logger

  @spec team_query(Durandal.query_args()) :: Ecto.Query.t()
  def team_query(args) do
    query = from(teams in Team)

    query
    |> do_where(id: args[:id])
    |> do_where(args[:where])
    |> do_where(args[:search])
    |> do_preload(args[:preload])
    |> do_order_by(args[:order_by])
    |> QueryHelper.query_select(args[:select])
    |> QueryHelper.limit_query(args[:limit] || 50)
  end

  @spec do_where(Ecto.Query.t(), list | map | nil) :: Ecto.Query.t()
  defp do_where(query, nil), do: query

  defp do_where(query, params) do
    params
    |> Enum.reduce(query, fn {key, value}, query_acc ->
      _where(query_acc, key, value)
    end)
  end

  @spec _where(Ecto.Query.t(), Atom.t(), any()) :: Ecto.Query.t()
  def _where(query, _, ""), do: query
  def _where(query, _, nil), do: query

  def _where(query, :id, id) do
    from teams in query,
      where: teams.id in ^List.wrap(id)
  end

  def _where(query, :name, name) do
    from teams in query,
      where: teams.name in ^List.wrap(name)
  end

  def _where(query, :universe_id, universe_id) do
    from teams in query,
      where: teams.universe_id in ^List.wrap(universe_id)
  end

  def _where(query, :inserted_after, timestamp) do
    from teams in query,
      where: teams.inserted_at >= ^timestamp
  end

  def _where(query, :inserted_before, timestamp) do
    from teams in query,
      where: teams.inserted_at < ^timestamp
  end

  def _where(query, :updated_after, timestamp) do
    from teams in query,
      where: teams.updated_at >= ^timestamp
  end

  def _where(query, :updated_before, timestamp) do
    from teams in query,
      where: teams.updated_at < ^timestamp
  end

  @spec do_order_by(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
  defp do_order_by(query, nil), do: query

  defp do_order_by(query, params) do
    params
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _order_by(query_acc, key)
    end)
  end

  @spec _order_by(Ecto.Query.t(), any()) :: Ecto.Query.t()

  def _order_by(query, "Name (A-Z)") do
    from(users in query,
      order_by: [asc: users.name]
    )
  end

  def _order_by(query, "Name (Z-A)") do
    from(users in query,
      order_by: [desc: users.name]
    )
  end

  def _order_by(query, "Newest first") do
    from teams in query,
      order_by: [desc: teams.inserted_at]
  end

  def _order_by(query, "Oldest first") do
    from teams in query,
      order_by: [asc: teams.inserted_at]
  end

  @spec do_preload(Ecto.Query.t(), List.t() | nil) :: Ecto.Query.t()
  defp do_preload(query, nil), do: query

  defp do_preload(query, preloads) do
    preloads
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _preload(query_acc, key)
    end)
  end

  def _preload(query, :universe) do
    from teams in query,
      left_join: game_universes in assoc(teams, :universe),
      preload: [universe: game_universes]
  end
end
