defmodule DurandalWeb.Live.Team.StationLiveTest do
  @moduledoc false
  use DurandalWeb.ConnCase
  alias Durandal.{Game, Player, Space}

  import Phoenix.LiveViewTest
  import Durandal.AccountFixtures, only: [user_fixture: 0]

  defp scenario_setup(%{user: user}) do
    # Custom data we're putting in
    leader2 = user_fixture()

    team_data = %{
      "$team1" => %{"name" => "Team 1 testname"},
      "$team2" => %{"name" => "Team 2 testname"}
    }

    user_data = %{
      "@leader1" => %{"name" => user.name, "roles" => "r1, r2"},
      "@leader2" => %{"name" => leader2.name, "roles" => "r3, r4"}
    }

    # Create it
    {:ok, %Game.Universe{id: _universe_id} = universe} =
      Game.ScenarioLib.load_from_file("basic_entities",
        user_data: user_data,
        team_data: team_data
      )

    team = Player.get_team(nil, where: [universe_id: universe.id, name: "Team 1 testname"])
    Durandal.Player.TeamMemberLib.update_selected_team(user.id, team.id)

    %{
      universe: universe,
      team: team
    }
  end

  describe "dashboard" do
    setup [:auth, :scenario_setup]

    test "live", %{conn: conn, user: _user, team: team, universe: _universe} do
      station = Space.get_station!(nil, where: [team_id: team.id, name: "Station 1"])

      # Lets select then!
      {:ok, view, _html} = live(conn, ~p"/team/station/#{station.id}")
      assert view |> has_element?("#command_command_type")

      # Try every command type, if it renders we're okay at this stage
      "station"
      |> Player.CommandLib.command_types()
      |> Map.values()
      |> Enum.each(fn command_name ->
        assert view
               |> element("#quick_add_command-form")
               |> render_change(%{command: %{command_type: command_name}})
      end)
    end
  end
end
