defmodule Durandal.PlayerFixtures do
  @moduledoc false

  alias Durandal.Player.Team
  import Durandal.GameFixtures, only: [universe_fixture: 0]
  import Durandal.AccountFixtures, only: [user_fixture: 0]

  @spec team_fixture(map) :: Team.t()
  def team_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    Team.changeset(
      %Team{},
      %{
        name: data["name"] || "team_name_#{r}",
        universe_id: data["universe_id"] || universe_fixture().id
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Player.TeamMember

  @spec team_member_fixture(map) :: TeamMember.t()
  def team_member_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    TeamMember.changeset(
      %TeamMember{},
      %{
        roles: data["roles"] || ["team_member_roles_#{r}_1", "team_member_roles_#{r}_2"],
        team_id: data["team_id"] || team_fixture().id,
        user_id: data["user_id"] || user_fixture().id
      }
    )
    |> Durandal.Repo.insert!()
  end

  alias Durandal.Player.Command

  @spec command_fixture(map) :: Command.t()
  def command_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    Command.changeset(
      %Command{},
      %{
        command_type: data["command_type"] || "command_type_#{r}",
        subject_type: data["subject_type"] || "subject_type_#{r}",
        subject_id: data["subject_id"] || "1489dbe3-fcfe-41d7-8925-f172a979456d",
        ordering: data["ordering"] || r,
        contents: data["contents"] || %{},
        team_id: data["team_id"] || team_fixture().id,
        user_id: data["user_id"] || user_fixture().id
      }
    )
    |> Durandal.Repo.insert!()
  end
end
