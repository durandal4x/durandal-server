defmodule Durandal.Player.TeamMemberQueries do
  @moduledoc false
  use DurandalMacros, :queries
  alias Durandal.Player.TeamMember
  require Logger

  @spec team_member_query(Durandal.query_args()) :: Ecto.Query.t()
  def team_member_query(args) do
    query = from(team_members in TeamMember)

    query
    |> do_where(team_id: args[:team_id])
    |> do_where(user_id: args[:user_id])
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

  def _where(query, :has_roles, roles) do
    from(team_members in query,
      where: ^roles in team_members.roles
    )
  end

  def _where(query, :not_has_roles, roles) do
    from(team_members in query,
      where: ^roles not in team_members.roles
    )
  end

  def _where(query, :enabled?, enabled?) do
    from team_members in query,
      where: team_members.enabled? in ^List.wrap(enabled?)
  end

  def _where(query, :team_id, team_id) do
    from team_members in query,
      where: team_members.team_id in ^List.wrap(team_id)
  end

  def _where(query, :user_id, user_id) do
    from team_members in query,
      where: team_members.user_id in ^List.wrap(user_id)
  end

  def _where(query, :inserted_after, timestamp) do
    from team_members in query,
      where: team_members.inserted_at >= ^timestamp
  end

  def _where(query, :inserted_before, timestamp) do
    from team_members in query,
      where: team_members.inserted_at < ^timestamp
  end

  def _where(query, :updated_after, timestamp) do
    from team_members in query,
      where: team_members.updated_at >= ^timestamp
  end

  def _where(query, :updated_before, timestamp) do
    from team_members in query,
      where: team_members.updated_at < ^timestamp
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

  def _order_by(query, "Enabled") do
    from team_members in query,
      order_by: [desc: team_members.enabled?]
  end

  def _order_by(query, "Disabled") do
    from team_members in query,
      order_by: [asc: team_members.enabled?]
  end

  def _order_by(query, "Newest first") do
    from team_members in query,
      order_by: [desc: team_members.inserted_at]
  end

  def _order_by(query, "Oldest first") do
    from team_members in query,
      order_by: [asc: team_members.inserted_at]
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
    from team_members in query,
      left_join: player_teams in assoc(team_members, :team),
      preload: [team: player_teams]
  end

  def _preload(query, :user) do
    from team_members in query,
      left_join: account_users in assoc(team_members, :user),
      preload: [user: account_users]
  end

  def count_team_members(team_id, args \\ []) do
    query = team_member_query([team_id: team_id] ++ args)
    Repo.aggregate(query, :count)
  end



  def list_all_enabled_team_memberships(nil), do: []
  def list_all_enabled_team_memberships(user_id) do
    query = from universes in Durandal.Game.Universe,
      join: teams in assoc(universes, :teams),
      join: team_members in assoc(teams, :team_members),
        where: team_members.user_id == ^user_id,
      where: team_members.enabled? == true,
      preload: [teams: {teams, team_members: team_members}],
      order_by: [asc: universes.name]

    Repo.all(query)
  end
end
