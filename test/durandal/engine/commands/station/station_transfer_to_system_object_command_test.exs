defmodule Durandal.Engine.Commands.StationTransferToSystemObjectCommandTest do
  use Durandal.SimCase
  alias Durandal.Engine.StationTransferToSystemObjectCommand
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

    system_object =
      system_object_fixture(%{
        "system_id" => system.id,
        "position" => [1_000, 1_000, 0],
        "velocity" => [0, 0, 0]
      })

    command =
      command_fixture(%{
        "command_type" => StationTransferToSystemObjectCommand.name(),
        "subject_type" => "station",
        "subject_id" => station.id,
        "ordering" => 0,
        "team_id" => team.id,
        "user_id" => user.id,
        "contents" => %{
          "system_object_id" => system_object.id,
          "orbit_distance" => 100
        }
      })

    {:ok, universe: universe, station: station, system_object: system_object, command: command}
  end

  test "perform transfer - 100 orbit distance", %{
    station: station,
    universe: universe,
    system_object: system_object,
    command: command
  } do
    assert station.velocity == [0, 0, 0]
    assert station.position == [0, 0, 0]
    assert station.universe_id == universe.id

    [result] = tick_universe(universe.id)
    assert result.command_logs[command.id] == ["Progressed transfer of #{station.id}"]
    command = Player.get_command!(command.id)
    assert command.progress == 7
    assert command.outcome["transfer"]["progress"] == 100

    station = Space.get_station!(station.id)
    assert station.velocity == [71, 71, 0]
    assert station.position == [71, 71, 0]

    # Now tick nine more times
    tick_universe(universe.id, 9)
    assert result.command_logs[command.id] == ["Progressed transfer of #{station.id}"]
    command = Player.get_command!(command.id)
    assert command.progress == 70
    assert command.outcome["transfer"]["progress"] == 1000

    station = Space.get_station!(station.id)
    assert station.velocity == [71, 71, 0]
    assert station.position == [707, 707, 0]

    # And then X more to get it 1 tick before the arrival
    tick_universe(universe.id, 3)
    assert result.command_logs[command.id] == ["Progressed transfer of #{station.id}"]
    command = Player.get_command!(command.id)
    assert command.progress == 91
    assert command.outcome["transfer"]["progress"] == 1300

    station = Space.get_station!(station.id)
    assert station.velocity == [70, 70, 0]
    assert station.position == [919, 919, 0]

    # Now with that one extra tick, should be on the final stage of transfer
    [result] = tick_universe(universe.id)
    assert result.command_logs[command.id] == ["Nearly completed transfer of #{station.id}"]

    command = Player.get_command!(command.id)
    assert command.progress == 99
    assert command.outcome["transfer"]["progress"] == 1414

    station = Space.get_station!(station.id)
    assert station.velocity == [10, 10, 0]
    assert station.position == [929, 929, 0]

    # One more tick to kill the command and velocity
    [result] = tick_universe(universe.id)
    assert result.command_logs[command.id] == ["Completed transfer of #{station.id}"]

    command = Player.get_command!(command.id)
    assert command.progress == 100
    station = Space.get_station!(station.id)
    assert station.velocity == [0, 0, 0]
    assert station.position == [934, 925, 0]
    assert station.orbiting_id == system_object.id

    # At this stage the station should have no commands
    station_command = Player.current_command_for_subject(station.id)
    assert station_command == nil
  end

  test "perform transfer - no orbit distance", %{
    station: station,
    universe: universe,
    command: command
  } do
    new_contents = Map.put(command.contents, "orbit_distance", 0)
    {:ok, _command} = Player.update_command(command, %{contents: new_contents})

    assert station.velocity == [0, 0, 0]
    assert station.position == [0, 0, 0]
    assert station.universe_id == universe.id

    [result] = tick_universe(universe.id)
    assert result.command_logs[command.id] == ["Progressed transfer of #{station.id}"]
    command = Player.get_command!(command.id)
    assert command.progress == 7
    assert command.outcome["transfer"]["progress"] == 100

    station = Space.get_station!(station.id)
    assert station.velocity == [71, 71, 0]
    assert station.position == [71, 71, 0]

    # Now tick nine more times
    tick_universe(universe.id, 9)
    assert result.command_logs[command.id] == ["Progressed transfer of #{station.id}"]
    command = Player.get_command!(command.id)
    assert command.progress == 70
    assert command.outcome["transfer"]["progress"] == 1000

    station = Space.get_station!(station.id)
    assert station.velocity == [71, 71, 0]
    assert station.position == [707, 707, 0]

    # And then X more to get it 1 tick before the arrival
    tick_universe(universe.id, 4)
    assert result.command_logs[command.id] == ["Progressed transfer of #{station.id}"]
    command = Player.get_command!(command.id)
    assert command.progress == 99
    assert command.outcome["transfer"]["progress"] == 1400

    station = Space.get_station!(station.id)
    assert station.velocity == [71, 71, 0]
    assert station.position == [990, 990, 0]

    # Now with that one extra tick, should be on the final stage of transfer
    [result] = tick_universe(universe.id)
    assert result.command_logs[command.id] == ["Nearly completed transfer of #{station.id}"]

    command = Player.get_command!(command.id)
    assert command.progress == 99
    assert command.outcome["transfer"]["progress"] == 1414

    station = Space.get_station!(station.id)
    assert station.velocity == [10, 10, 0]
    assert station.position == [1_000, 1_000, 0]

    # One more tick to kill the command and velocity
    [result] = tick_universe(universe.id)
    assert result.command_logs[command.id] == ["Completed transfer of #{station.id}"]

    command = Player.get_command!(command.id)
    assert command.progress == 100
    station = Space.get_station!(station.id)
    assert station.velocity == [0, 0, 0]
    assert station.position == [1_000, 1_000, 0]

    # At this stage the station should have no commands
    station_command = Player.current_command_for_subject(station.id)
    assert station_command == nil
  end
end
