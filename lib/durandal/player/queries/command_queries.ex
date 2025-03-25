defmodule Durandal.Player.CommandQueries do
  @moduledoc false
  use DurandalMacros, :queries
  alias Durandal.Player.Command
  require Logger

  @spec command_query(Durandal.query_args()) :: Ecto.Query.t()
  def command_query(args) do
    query = from(commands in Command)

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
    from commands in query,
      where: commands.id in ^List.wrap(id)
  end

  def _where(query, :command_type, command_type) do
    from commands in query,
      where: commands.command_type in ^List.wrap(command_type)
  end

  def _where(query, :subject_type, subject_type) do
    from commands in query,
      where: commands.subject_type in ^List.wrap(subject_type)
  end

  def _where(query, :subject_id, subject_id) do
    from commands in query,
      where: commands.subject_id in ^List.wrap(subject_id)
  end

  def _where(query, :universe_id, universe_id) do
    from commands in query,
      where: commands.universe_id in ^List.wrap(universe_id)
  end

  def _where(query, :ordering, ordering) do
    from commands in query,
      where: commands.ordering in ^List.wrap(ordering)
  end

  def _where(query, :contents, contents) do
    from commands in query,
      where: commands.contents in ^List.wrap(contents)
  end

  def _where(query, :team_id, team_id) do
    from commands in query,
      where: commands.team_id in ^List.wrap(team_id)
  end

  def _where(query, :user_id, user_id) do
    from commands in query,
      where: commands.user_id in ^List.wrap(user_id)
  end

  def _where(query, :inserted_after, timestamp) do
    from commands in query,
      where: commands.inserted_at >= ^timestamp
  end

  def _where(query, :inserted_before, timestamp) do
    from commands in query,
      where: commands.inserted_at < ^timestamp
  end

  def _where(query, :updated_after, timestamp) do
    from commands in query,
      where: commands.updated_at >= ^timestamp
  end

  def _where(query, :updated_before, timestamp) do
    from commands in query,
      where: commands.updated_at < ^timestamp
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

  def _order_by(query, "Priority") do
    from commands in query,
      order_by: [asc: commands.ordering]
  end

  def _order_by(query, "Newest first") do
    from commands in query,
      order_by: [desc: commands.inserted_at]
  end

  def _order_by(query, "Oldest first") do
    from commands in query,
      order_by: [asc: commands.inserted_at]
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

  def _preload(query, :team) do
    from commands in query,
      left_join: player_teams in assoc(commands, :team),
      preload: [team: player_teams]
  end

  def _preload(query, :user) do
    from commands in query,
      left_join: account_users in assoc(commands, :user),
      preload: [user: account_users]
  end

  def _preload(query, :universe) do
    from commands in query,
      left_join: game_universes in assoc(commands, :universe),
      preload: [universe: game_universes]
  end

  @spec next_ordering_for_subject(Durandal.ship_id() | Durandal.station_id()) :: non_neg_integer()
  def next_ordering_for_subject(subject_id) do
    query =
      from commands in Command,
        where: commands.subject_id == ^subject_id,
        order_by: [desc: commands.ordering],
        limit: 1,
        select: commands.ordering

    (Repo.one(query) || -1) + 1
  end

  def pull_most_recent_commands(universe_id) do
    min_orderings_cte =
      from(
        c in Command,
        group_by: [c.subject_id],
        select: %{subject_id: c.subject_id, min_ordering: min(c.ordering)}
      )

    query =
      from(
        t1 in Command,
        join: mo in subquery(min_orderings_cte),
        on: t1.subject_id == mo.subject_id and t1.ordering == mo.min_ordering,
        where: t1.universe_id == ^universe_id,
        select: t1
      )

    Repo.all(query)
  end
end
