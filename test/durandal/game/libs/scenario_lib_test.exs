defmodule Durandal.Game.Libs.ScenarioLibTest do
  @moduledoc false
  use Durandal.DataCase, async: true
  import Durandal.AccountFixtures, only: [user_fixture: 0]
  alias Durandal.{Game, Player, Space}

  # Deleting a universe is something we don't want to do often but there are a lot of moving parts and caches to check
  test "perform task" do
    # Custom data we're putting in
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

    # Create it
    {:ok, %Game.Universe{id: universe_id}} =
      Game.ScenarioLib.load_from_file("basic_entities",
        user_data: user_data,
        team_data: team_data
      )

    # Ensure the teams are setup the way we expected
    teams = Player.list_teams(where: [universe_id: universe_id])
    assert Enum.count(teams) == 2
    assert Enum.map(teams, & &1.name) |> Enum.sort() == ["Team 1 testname", "Team 2 testname"]

    # Ensure the team_members are setup correctly
    team_members =
      Player.list_team_members(where: [universe_id: universe_id])
      |> Map.new(fn tm -> {tm.user_id, tm} end)

    assert Enum.count(team_members) == 2
    assert team_members[leader1.id].roles == ["r1", "r2"]
    assert team_members[leader2.id].roles == ["r3", "r4"]

    refute team_members[leader1.id].team_id == team_members[leader2.id].team_id

    # Assert all the ids got added correctly
    Space.list_ships(where: [universe_id: universe_id])
    |> Enum.each(fn s ->
      assert s.team_id
      assert s.type_id
      assert s.system_id
      assert s.universe_id
    end)

    Space.list_stations(where: [universe_id: universe_id])
    |> Enum.each(fn s ->
      assert s.team_id
      assert s.system_id
      assert s.universe_id
    end)

    Player.list_commands(where: [universe_id: universe_id])
    |> Enum.each(fn c ->
      assert c.subject_id
      assert c.team_id
      assert c.user_id
      assert c.universe_id
    end)

    # Ensure the commands got added
    ship_commands =
      Player.list_commands(where: [universe_id: universe_id])
      |> Enum.filter(fn c -> c.subject_type == "ship" end)

    assert Enum.count(ship_commands) == 4
    # TODO: check the commands a bit better?

    Durandal.SimCase.tear_down(universe_id)
  end
end
