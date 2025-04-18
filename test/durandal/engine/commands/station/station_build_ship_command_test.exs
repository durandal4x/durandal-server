defmodule Durandal.Engine.Commands.StationBuildShipCommandTest do
  use Durandal.SimCase
  alias Durandal.Engine.StationBuildShipCommand
  alias Durandal.{Space, Player}

  setup do
    universe = start_universe("empty", [])

    team = team_fixture(%{"universe_id" => universe.id})
    system = system_fixture(%{"universe_id" => universe.id})
    user = user_fixture()

    team_member_fixture(%{
      "user_id" => user.id,
      "team_id" => team.id
    })

    station =
      station_fixture(%{
        "system_id" => system.id,
        "team_id" => team.id,
        "position" => [0, 0, 0],
        "velocity" => [0, 0, 0]
      })

    ship_type =
      ship_type_fixture(%{
        "universe_id" => universe.id,
        "acceleration" => 100,
        "build_time" => 30
      })

    command =
      command_fixture(%{
        "command_type" => StationBuildShipCommand.name(),
        "subject_type" => "station",
        "subject_id" => station.id,
        "ordering" => 0,
        "team_id" => team.id,
        "user_id" => user.id,
        "contents" => %{
          "ship_type_id" => ship_type.id
        }
      })

    {:ok, universe: universe, station: station, ship_type: ship_type, command: command}
  end

  test "perform transfer", %{station: station, universe: universe, command: command} do
    ships = Space.list_ships(where: [universe_id: universe.id, team_id: station.team_id])
    assert Enum.empty?(ships)

    command = Player.get_command!(command.id)
    assert command.outcome == nil

    _ = tick_universe(universe.id)

    [ship] = Space.list_ships(where: [universe_id: universe.id, team_id: station.team_id])
    assert ship.team_id == station.team_id
    assert ship.docked_with_id == station.id
    assert ship.build_progress == 10
    ship_id = ship.id

    command = Player.get_command!(command.id)
    assert command.outcome["ship_id"] == ship.id
    assert command.progress == 33

    _ = tick_universe(universe.id)

    ship = Space.get_ship!(ship_id)
    assert ship.build_progress == 20

    command = Player.get_command!(command.id)
    assert command.progress == 66

    _ = tick_universe(universe.id)

    ship = Space.get_ship!(ship_id)
    assert ship.build_progress == 30

    command = Player.get_command!(command.id)
    assert command.progress == 100

    # Ship is already complete, should have no errors etc
    _ = tick_universe(universe.id)

    ship = Space.get_ship!(ship_id)
    assert ship.build_progress == 30

    command = Player.get_command!(command.id)
    assert command.progress == 100
  end
end
