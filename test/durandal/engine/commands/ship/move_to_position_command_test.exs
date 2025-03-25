defmodule Durandal.Engine.Commands.ShipMoveToPositionCommandTest do
  use Durandal.SimCase
  alias Durandal.Engine.ShipMoveToPositionCommand
  alias Durandal.Space

  test "test move to position" do
    universe = start_universe("empty", [])

    team = team_fixture(%{"universe_id" => universe.id})
    system = system_fixture(%{"universe_id" => universe.id})
    user = user_fixture()

    team_member_fixture(%{
      "user_id" => user.id,
      "team_id" => team.id
    })

    ship =
      ship_fixture(%{
        "system_id" => system.id,
        "team_id" => team.id,
        "position" => [0, 0, 0],
        "velocity" => [0, 0, 0]
      })

    command_fixture(%{
      "command_type" => ShipMoveToPositionCommand.name(),
      "subject_type" => "ship",
      "subject_id" => ship.id,
      "ordering" => 0,
      "team_id" => team.id,
      "user_id" => user.id,
      "contents" => %{
        "position" => [100_00, -100_00, 0]
      }
    })

    # A second command, to ensure we're grabbing the correct one
    command_fixture(%{
      "command_type" => ShipMoveToPositionCommand.name(),
      "subject_type" => "ship",
      "subject_id" => ship.id,
      "ordering" => 1,
      "team_id" => team.id,
      "user_id" => user.id,
      "contents" => %{
        "position" => [0, 0, 0]
      }
    })

    ship = Space.get_ship!(ship.id)
    assert ship.velocity == [0, 0, 0]
    assert ship.position == [0, 0, 0]
    assert ship.universe_id == universe.id

    tick_universe(universe.id)

    ship = Space.get_ship!(ship.id)
    assert ship.velocity == [71, -71, 0]
    assert ship.position == [71, -71, 0]

    # If we tick again we should be going even faster!
    tick_universe(universe.id)

    ship = Space.get_ship!(ship.id)
    assert ship.velocity == [142, -142, 0]
    assert ship.position == [213, -213, 0]

    tear_down(universe.id)
  end
end
