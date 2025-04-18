defmodule Durandal.Engine.Commands.ShipDockWithStationCommandTest do
  use Durandal.SimCase
  alias Durandal.Engine.ShipDockWithStationCommand
  alias Durandal.{Space, Player}

  setup _tags do
    universe = start_universe("empty", [])

    team = team_fixture(%{"universe_id" => universe.id})
    system = system_fixture(%{"universe_id" => universe.id})
    user = user_fixture()

    team_member_fixture(%{
      "user_id" => user.id,
      "team_id" => team.id
    })

    ship_type =
      ship_type_fixture(%{
        "universe_id" => universe.id,
        "acceleration" => 100
      })

    ship =
      ship_fixture(%{
        "system_id" => system.id,
        "team_id" => team.id,
        "type_id" => ship_type.id,
        "position" => [0, 0, 0],
        "velocity" => [0, 0, 0]
      })

    station =
      station_fixture(%{
        "system_id" => system.id,
        "team_id" => team.id,
        "position" => [1_000, 1_000, 0],
        "velocity" => [0, 0, 0]
      })

    command =
      command_fixture(%{
        "command_type" => ShipDockWithStationCommand.name(),
        "subject_type" => "ship",
        "subject_id" => ship.id,
        "ordering" => 0,
        "team_id" => team.id,
        "user_id" => user.id,
        "contents" => %{
          "station_id" => station.id
        }
      })

    {:ok, universe: universe, ship: ship, station: station, command: command}
  end

  test "undock successfully", %{
    universe: universe,
    ship: ship,
    station: station,
    command: command
  } do
    # We need to move it a bit closer to the station
    {:ok, ship} = Space.update_ship(ship, %{position: [900, 900, 0]})
    assert ship.docked_with_id == nil

    [result] = tick_universe(universe.id)
    assert result.command_logs[command.id] == ["Docked #{ship.id} with #{station.id}"]

    ship = Space.get_ship!(ship.id)
    assert ship.docked_with_id == station.id

    command = Player.get_command(command.id)
    assert command.progress == 100
  end

  test "docking failure - wrong team", %{
    universe: universe,
    ship: ship,
    station: station,
    command: command
  } do
    # Tweak the team of the station
    team2 = team_fixture(%{"universe_id" => universe.id})
    {:ok, station} = Space.update_station(station, %{team: team2.id})

    assert ship.docked_with_id == nil

    [result] = tick_universe(universe.id)

    assert result.command_logs[command.id] == [
             "Unable to dock #{ship.id} with #{station.id} because docking_failure_distance_too_great"
           ]

    ship = Space.get_ship!(ship.id)
    assert ship.docked_with_id == nil

    command = Player.get_command(command.id)
    assert command.progress == 0
  end

  test "docking failure - too far away", %{
    universe: universe,
    ship: ship,
    station: station,
    command: command
  } do
    assert ship.docked_with_id == nil

    [result] = tick_universe(universe.id)

    assert result.command_logs[command.id] == [
             "Unable to dock #{ship.id} with #{station.id} because docking_failure_distance_too_great"
           ]

    ship = Space.get_ship!(ship.id)
    assert ship.docked_with_id == nil

    command = Player.get_command(command.id)
    assert command.progress == 0
  end
end
