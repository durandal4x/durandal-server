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
        type: data["type"] || "command_type_#{r}",
        target: data["target"] || "9b8c9217-72ec-40cb-9951-798e916288af",
        ordering: data["ordering"] || r,
        contents: data["contents"] || %{},
        team: data["team"] || team_fixture().id,
        user: data["user"] || user_fixture().id
      }
    )
    |> Durandal.Repo.insert!()
  end
end
