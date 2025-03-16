defmodule Durandal.TeamMemberLibTest do
  @moduledoc false
  alias Durandal.Player.TeamMember
  alias Durandal.Player
  use Durandal.DataCase, async: true

  import Durandal.AccountFixtures, only: [user_fixture: 0]
  alias Durandal.PlayerFixtures
  alias Durandal.GameFixtures

  defp valid_attrs do
    %{
      roles: ["String one", "String two"],
      team_id: PlayerFixtures.team_fixture().id,
      user_id: user_fixture().id,
      universe_id: GameFixtures.universe_fixture().id
    }
  end

  defp update_attrs do
    %{
      roles: ["String one", "String two", "String three"],
      team_id: PlayerFixtures.team_fixture().id,
      user_id: user_fixture().id,
      universe_id: GameFixtures.universe_fixture().id
    }
  end

  defp invalid_attrs do
    %{
      roles: nil,
      team_id: nil,
      user_id: nil,
      universe_id: nil
    }
  end

  describe "team_member" do
    alias Durandal.Player.TeamMember

    test "team_member_query/0 returns a query" do
      q = Player.team_member_query([])
      assert %Ecto.Query{} = q
    end

    test "list_team_member/0 returns team_member" do
      # No team_member yet
      assert Player.list_team_members([]) == []

      # Add a team_member
      PlayerFixtures.team_member_fixture()
      assert Player.list_team_members([]) != []
    end

    test "get_team_member!/1 and get_team_member/1 returns the team_member with given id" do
      team_member = PlayerFixtures.team_member_fixture()
      assert Player.get_team_member!(team_member.team_id, team_member.user_id) == team_member
      assert Player.get_team_member(team_member.team_id, team_member.user_id) == team_member
    end

    test "create_team_member/1 with valid data creates a team_member" do
      assert {:ok, %TeamMember{} = team_member} =
               Player.create_team_member(valid_attrs())

      assert team_member.roles == ["String one", "String two"]
    end

    test "create_team_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Player.create_team_member(invalid_attrs())
    end

    test "update_team_member/2 with valid data updates the team_member" do
      team_member = PlayerFixtures.team_member_fixture()

      assert {:ok, %TeamMember{} = team_member} =
               Player.update_team_member(team_member, update_attrs())

      assert team_member.roles == ["String one", "String two", "String three"]
    end

    test "update_team_member/2 with invalid data returns error changeset" do
      team_member = PlayerFixtures.team_member_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Player.update_team_member(team_member, invalid_attrs())

      assert team_member == Player.get_team_member!(team_member.team_id, team_member.user_id)
    end

    test "delete_team_member/1 deletes the team_member" do
      team_member = PlayerFixtures.team_member_fixture()
      assert {:ok, %TeamMember{}} = Player.delete_team_member(team_member)

      assert_raise Ecto.NoResultsError, fn ->
        Player.get_team_member!(team_member.team_id, team_member.user_id)
      end

      assert Player.get_team_member(team_member.team_id, team_member.user_id) == nil
    end

    test "change_team_member/1 returns a team_member changeset" do
      team_member = PlayerFixtures.team_member_fixture()
      assert %Ecto.Changeset{} = Player.change_team_member(team_member)
    end
  end
end
