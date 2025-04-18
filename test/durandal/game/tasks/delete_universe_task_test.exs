defmodule Durandal.Game.DeleteUniverseTaskTest do
  @moduledoc false
  use Durandal.DataCase, async: true
  import Durandal.AccountFixtures, only: [user_fixture: 0]
  alias Durandal.{Game, Player}

  # Deleting a universe is something we don't want to do often but there are a lot of moving parts and caches to check
  test "perform task" do
    leader1 = user_fixture()
    leader2 = user_fixture()

    team_data = %{
      "$team1" => %{"name" => "Team 1 testname"},
      "$team2" => %{"name" => "Team 2 testname"}
    }

    user_data = %{
      "@leader1" => %{"name" => leader1.name, "roles" => "r1, r2"},
      "@leader2" => %{"name" => leader2.name, "roles" => "r3, r4"}
    }

    {:ok, %Game.Universe{id: universe_id}} =
      Game.ScenarioLib.load_from_file("basic_entities",
        user_data: user_data,
        team_data: team_data
      )

    assert Game.get_universe(universe_id) != nil
    assert Game.get_universe_by_id(universe_id) != nil

    teams = Player.list_teams(where: [universe_id: universe_id])

    teams
    |> Enum.each(fn team ->
      assert Player.get_team(team.id) != nil
      assert Player.get_team_by_id(team.id) != nil
    end)

    {:ok, _universe} = Game.DeleteUniverseTask.perform(universe_id)

    assert Game.get_universe(universe_id) == nil
    assert Game.get_universe_by_id(universe_id) == nil

    teams
    |> Enum.each(fn team ->
      assert Player.get_team(team.id) == nil
      assert Player.get_team_by_id(team.id) == nil
    end)
  end
end
