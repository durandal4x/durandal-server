defmodule Durandal.Player do
  @moduledoc """

  """

  # Teams
  alias Durandal.Player.{Team, TeamLib, TeamQueries}

  @doc false
  @spec team_topic(Durandal.team_id()) :: String.t()
  defdelegate team_topic(team_id), to: TeamLib, as: :topic

  @doc false
  @spec team_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate team_query(args), to: TeamQueries

  @doc section: :team
  @spec list_teams(Durandal.query_args()) :: [Team.t()]
  defdelegate list_teams(args), to: TeamLib

  @doc section: :team
  @spec get_team!(Team.id(), Durandal.query_args()) :: Team.t()
  defdelegate get_team!(team_id, query_args \\ []), to: TeamLib

  @doc section: :team
  @spec get_team(Team.id(), Durandal.query_args()) :: Team.t() | nil
  defdelegate get_team(team_id, query_args \\ []), to: TeamLib

  @doc section: :team
  @spec create_team(map) :: {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_team(attrs), to: TeamLib

  @doc section: :team
  @spec update_team(Team, map) :: {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_team(team, attrs), to: TeamLib

  @doc section: :team
  @spec delete_team(Team.t()) :: {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_team(team), to: TeamLib

  @doc section: :team
  @spec change_team(Team.t(), map) :: Ecto.Changeset.t()
  defdelegate change_team(team, attrs \\ %{}), to: TeamLib

  # TeamMembers
  alias Durandal.Player.{TeamMember, TeamMemberLib, TeamMemberQueries}

  @doc false
  @spec team_member_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate team_member_query(args), to: TeamMemberQueries

  @doc section: :team_member
  @spec list_team_members(Durandal.query_args()) :: [TeamMember.t()]
  defdelegate list_team_members(args), to: TeamMemberLib

  @doc section: :team_member
  @spec get_team_member!(Durandal.team_id(), Durandal.user_id(), Durandal.query_args()) ::
          TeamMember.t()
  defdelegate get_team_member!(team_id, user_id, query_args \\ []), to: TeamMemberLib

  @doc section: :team_member
  @spec get_team_member(Durandal.team_id(), Durandal.user_id(), Durandal.query_args()) ::
          TeamMember.t() | nil
  defdelegate get_team_member(team_id, user_id, query_args \\ []), to: TeamMemberLib

  @doc section: :team_member
  @spec create_team_member(map) :: {:ok, TeamMember.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_team_member(attrs), to: TeamMemberLib

  @doc section: :team_member
  @spec update_team_member(TeamMember, map) ::
          {:ok, TeamMember.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_team_member(team_member, attrs), to: TeamMemberLib

  @doc section: :team_member
  @spec delete_team_member(TeamMember.t()) :: {:ok, TeamMember.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_team_member(team_member), to: TeamMemberLib

  @doc section: :team_member
  @spec change_team_member(TeamMember.t(), map) :: Ecto.Changeset.t()
  defdelegate change_team_member(team_member, attrs \\ %{}), to: TeamMemberLib

  # Commands
  alias Durandal.Player.{Command, CommandLib, CommandQueries}

  @doc false
  @spec command_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate command_query(args), to: CommandQueries

  @doc section: :command
  @spec list_commands(Durandal.query_args()) :: [Command.t()]
  defdelegate list_commands(args), to: CommandLib

  @doc section: :command
  @spec get_command!(Command.id(), Durandal.query_args()) :: Command.t()
  defdelegate get_command!(command_id, query_args \\ []), to: CommandLib

  @doc section: :command
  @spec get_command(Command.id(), Durandal.query_args()) :: Command.t() | nil
  defdelegate get_command(command_id, query_args \\ []), to: CommandLib

  @doc section: :command
  @spec create_command(map) :: {:ok, Command.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_command(attrs), to: CommandLib

  @doc section: :command
  @spec update_command(Command, map) :: {:ok, Command.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_command(command, attrs), to: CommandLib

  @doc section: :command
  @spec delete_command(Command.t()) :: {:ok, Command.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_command(command), to: CommandLib

  @doc section: :command
  @spec change_command(Command.t(), map) :: Ecto.Changeset.t()
  defdelegate change_command(command, attrs \\ %{}), to: CommandLib
end
