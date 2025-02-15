defmodule Durandal.Player.TeamLib do
  @moduledoc """
  Library of team related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Player.{Team, TeamQueries}

  @spec topic(Durandal.team_id()) :: String.t()
  def topic(team_id), do: "Durandal.Player.Team:#{team_id}"

  @doc """
  Returns the list of teams.

  ## Examples

      iex> list_teams()
      [%Team{}, ...]

  """
  @spec list_teams(Durandal.query_args()) :: [Team.t()]
  def list_teams(query_args) do
    query_args
    |> TeamQueries.team_query()
    |> Repo.all()
  end

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %Team{}

      iex> get_team!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_team!(Team.id(), Durandal.query_args()) :: Team.t()
  def get_team!(team_id, query_args \\ []) do
    (query_args ++ [id: team_id])
    |> TeamQueries.team_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single team.

  Returns nil if the Team does not exist.

  ## Examples

      iex> get_team("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %Team{}

      iex> get_team("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_team(Team.id(), Durandal.query_args()) :: Team.t() | nil
  def get_team(team_id, query_args \\ []) do
    (query_args ++ [id: team_id])
    |> TeamQueries.team_query()
    |> Repo.one()
  end

  @doc """
  Creates a team.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %Team{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_team(map) :: {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  def create_team(attrs) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
    |> Durandal.broadcast_on_ok(&topic/1, :team, %{event: :created_team})
    |> Durandal.broadcast_on_ok({&Durandal.Game.universe_topic/1, :universe_id}, :team, %{
      event: :created_team
    })
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_team(Team.t(), map) :: {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
    |> Durandal.broadcast_on_ok(&topic/1, :team, %{event: :updated_team})
    |> Durandal.broadcast_on_ok({&Durandal.Game.universe_topic/1, :universe_id}, :team, %{
      event: :updated_team
    })
  end

  @doc """
  Deletes a team.

  ## Examples

      iex> delete_team(team)
      {:ok, %Team{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_team(Team.t()) :: {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  def delete_team(%Team{} = team) do
    Repo.delete(team)
    |> Durandal.broadcast_on_ok(&topic/1, :team, %{event: :deleted_team})
    |> Durandal.broadcast_on_ok({&Durandal.Game.universe_topic/1, :universe_id}, :team, %{
      event: :deleted_team
    })
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{data: %Team{}}

  """
  @spec change_team(Team.t(), map) :: Ecto.Changeset.t()
  def change_team(%Team{} = team, attrs \\ %{}) do
    Team.changeset(team, attrs)
  end
end
