defmodule DurandalWeb.Live.Team.DashboardLiveTest do
  @moduledoc false
  use DurandalWeb.ConnCase
  alias Durandal.{Game, Player, Space}

  import Phoenix.LiveViewTest
  import Durandal.AccountFixtures, only: [user_fixture: 0]
  # import Durandal.SimCase

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

    %{
      universe: universe
    }
  end

  describe "dashboard" do
    setup [:auth, :scenario_setup]

    test "live", %{conn: conn, user: user, universe: universe} do
      # No team selected
      {:ok, _view, html} = live(conn, ~p"/team/dashboard")
      assert html =~ "No team selected, you can select one using"

      team = Player.get_team(nil, where: [universe_id: universe.id, name: "Team 1 testname"])

      # Lets select then!
      Durandal.Player.TeamMemberLib.update_selected_team(user.id, team.id)

      {:ok, view, html} = live(conn, ~p"/team/dashboard")
      refute html =~ "No team selected, you can select one using"

      assert view |> has_element?("#ships")
      assert view |> has_element?("#stations")
      assert view |> has_element?("#ships")
      assert view |> has_element?("#simple_resources-column")
      assert view |> has_element?("#composite_resources-column")
      assert view |> has_element?("#combined_simple_resources-column")
      assert view |> has_element?("#combined_composite_resources-column")

      # Now we want to test the view for every ship and every station
      Space.list_ships(where: [team_id: team.id])
      |> Enum.each(fn %{id: ship_id} ->
        {:ok, view, _html} = live(conn, ~p"/team/ship/#{ship_id}")
        assert view |> has_element?("#simple-resources-table")
        assert view |> has_element?("#composite-resources-table")
      end)

      Space.list_stations(where: [team_id: team.id])
      |> Enum.each(fn %{id: station_id} ->
        {:ok, view, _html} = live(conn, ~p"/team/station/#{station_id}")
        assert view |> has_element?("#simple-resources-table")
        assert view |> has_element?("#composite-resources-table")
      end)
    end
  end
end
