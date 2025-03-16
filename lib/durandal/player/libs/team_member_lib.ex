defmodule Durandal.Player.TeamMemberLib do
  @moduledoc """
  Library of team_member related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Player.{TeamMember, TeamMemberQueries}

  @doc """
  Returns the list of team_members.

  ## Examples

      iex> list_team_members()
      [%TeamMember{}, ...]

  """
  @spec list_team_members(Durandal.query_args()) :: [TeamMember.t()]
  def list_team_members(query_args) do
    query_args
    |> TeamMemberQueries.team_member_query()
    |> Repo.all()
  end

  @doc """
  Gets a single team_member.

  Raises `Ecto.NoResultsError` if the TeamMember does not exist.

  ## Examples

      iex> get_team_member!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %TeamMember{}

      iex> get_team_member!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_team_member!(Durandal.team_id(), Durandal.user_id(), Durandal.query_args()) ::
          TeamMember.t()
  def get_team_member!(team_id, user_id, query_args \\ []) do
    (query_args ++ [team_id: team_id, user_id: user_id])
    |> TeamMemberQueries.team_member_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single team_member.

  Returns nil if the TeamMember does not exist.

  ## Examples

      iex> get_team_member("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %TeamMember{}

      iex> get_team_member("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_team_member(Durandal.team_id(), Durandal.user_id(), Durandal.query_args()) ::
          TeamMember.t() | nil
  def get_team_member(team_id, user_id, query_args \\ []) do
    (query_args ++ [team_id: team_id, user_id: user_id])
    |> TeamMemberQueries.team_member_query()
    |> Repo.one()
  end

  @doc """
  Gets a single team_member by its id. If no team_member is found, returns `nil`.

  Makes use of a Cache

  ## Examples

      iex> get_team_member_by_id("09f4e0d9-13d1-4a32-8121-d52423dd8e7c")
      %User{}

      iex> get_team_member_by_id("310dcab9-e7c2-4fc0-acd6-98035376a7be")
      nil
  """
  @spec get_team_member_by_id(Durandal.team_id(), Durandal.user_id()) :: TeamMember.t() | nil
  def get_team_member_by_id(nil, _), do: nil
  def get_team_member_by_id(_, nil), do: nil
  def get_team_member_by_id(team_id, user_id) do
    case Cachex.get(:team_member_by_id_cache, "#{team_id}:#{user_id}") do
      {:ok, nil} ->
        team_member = do_get_team_member_by_id(team_id, user_id)
        Cachex.put(:team_member_by_id_cache, "#{team_id}:#{user_id}", team_member)
        team_member

      {:ok, value} ->
        value
    end
  end

  @spec do_get_team_member_by_id(Durandal.team_id(), Durandal.user_id()) :: TeamMember.t() | nil
  defp do_get_team_member_by_id(team_id, user_id) do
    TeamMemberQueries.team_member_query(team_id: team_id, user_id: user_id, limit: 1)
    |> Repo.one()
  end

  @doc """
  Creates a team_member.

  ## Examples

      iex> create_team_member(%{field: value})
      {:ok, %TeamMember{}}

      iex> create_team_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_team_member(map) :: {:ok, TeamMember.t()} | {:error, Ecto.Changeset.t()}
  def create_team_member(attrs) do
    %TeamMember{}
    |> TeamMember.changeset(attrs)
    |> Repo.insert()
    |> update_team_member_count
    |> Durandal.broadcast_on_ok({&Durandal.Player.TeamLib.topic/1, :team_id}, :team_member, %{event: :created_team_member})
  end

  @doc """
  Updates a team_member.

  ## Examples

      iex> update_team_member(team_member, %{field: new_value})
      {:ok, %TeamMember{}}

      iex> update_team_member(team_member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_team_member(TeamMember.t(), map) ::
          {:ok, TeamMember.t()} | {:error, Ecto.Changeset.t()}
  def update_team_member(%TeamMember{} = team_member, attrs) do
    team_member
    |> TeamMember.changeset(attrs)
    |> Repo.update()
    |> update_team_member_count
    |> Durandal.broadcast_on_ok({&Durandal.Player.TeamLib.topic/1, :team_id}, :team_member, %{event: :updated_team_member})
    |> Durandal.invalidate_cache_on_ok(:team_member_by_id_cache)
  end

  @doc """
  Deletes a team_member.

  ## Examples

      iex> delete_team_member(team_member)
      {:ok, %TeamMember{}}

      iex> delete_team_member(team_member)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_team_member(TeamMember.t()) :: {:ok, TeamMember.t()} | {:error, Ecto.Changeset.t()}
  def delete_team_member(%TeamMember{} = team_member) do
    Repo.delete(team_member)
    |> update_team_member_count
    |> Durandal.broadcast_on_ok({&Durandal.Player.TeamLib.topic/1, :team_id}, :team_member, %{event: :deleted_team_member})
    |> Durandal.invalidate_cache_on_ok(:team_member_by_id_cache)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team_member changes.

  ## Examples

      iex> change_team_member(team_member)
      %Ecto.Changeset{data: %TeamMember{}}

  """
  @spec change_team_member(TeamMember.t(), map) :: Ecto.Changeset.t()
  def change_team_member(%TeamMember{} = team_member, attrs \\ %{}) do
    TeamMember.changeset(team_member, attrs)
  end

  defp update_team_member_count({:ok, team_member} = v) do
    Durandal.Player.TeamLib.recalculate_member_count(team_member.team_id)
    v
  end
  defp update_team_member_count(v), do: v

  @doc """
  Update the `current_team` setting for a player.
  """
  def update_selected_team(user_id, nil) do
    Durandal.Settings.set_user_setting_value(user_id, "current_universe_id", nil)
    Durandal.Settings.set_user_setting_value(user_id, "current_team_id", nil)
  end
  def update_selected_team(user_id, team_id) do
    # TODO: Perform a check to ensure they are allowed to change team here
    team = Durandal.Player.get_team_by_id(team_id)

    Durandal.Settings.set_user_setting_value(user_id, "current_universe_id", team.universe_id)
    Durandal.Settings.set_user_setting_value(user_id, "current_team_id", team_id)
  end
end
