defmodule Durandal.TeamLibTest do
  @moduledoc false
  alias Durandal.Player.Team
  alias Durandal.Player
  use Durandal.DataCase, async: true

  import Durandal.GameFixtures, only: [universe_fixture: 0]
  alias Durandal.PlayerFixtures

  defp valid_attrs do
    %{
      name: "some name",
      universe_id: universe_fixture().id
    }
  end

  defp update_attrs do
    %{
      name: "some updated name",
      universe_id: universe_fixture().id
    }
  end

  defp invalid_attrs do
    %{
      name: nil,
      universe_id: nil
    }
  end

  describe "team" do
    alias Durandal.Player.Team

    test "team_query/0 returns a query" do
      q = Player.team_query([])
      assert %Ecto.Query{} = q
    end

    test "list_team/0 returns team" do
      # No team yet
      assert Player.list_teams([]) == []

      # Add a team
      PlayerFixtures.team_fixture()
      assert Player.list_teams([]) != []
    end

    test "get_team!/1 and get_team/1 returns the team with given id" do
      team = PlayerFixtures.team_fixture()
      assert Player.get_team!(team.id) == team
      assert Player.get_team(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      assert {:ok, %Team{} = team} =
               Player.create_team(valid_attrs())

      assert team.name == "some name"
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Player.create_team(invalid_attrs())
    end

    test "update_team/2 with valid data updates the team" do
      team = PlayerFixtures.team_fixture()

      assert {:ok, %Team{} = team} =
               Player.update_team(team, update_attrs())

      assert team.name == "some updated name"
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = PlayerFixtures.team_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Player.update_team(team, invalid_attrs())

      assert team == Player.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = PlayerFixtures.team_fixture()
      assert {:ok, %Team{}} = Player.delete_team(team)

      assert_raise Ecto.NoResultsError, fn ->
        Player.get_team!(team.id)
      end

      assert Player.get_team(team.id) == nil
    end

    test "change_team/1 returns a team changeset" do
      team = PlayerFixtures.team_fixture()
      assert %Ecto.Changeset{} = Player.change_team(team)
    end
  end
end
