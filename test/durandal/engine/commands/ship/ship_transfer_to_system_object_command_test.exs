defmodule Durandal.Engine.Commands.ShipTransferToSystemObjectCommandTest do
  use Durandal.SimCase
  alias Durandal.Engine.ShipTransferToSystemObjectCommand
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

    system_object =
      system_object_fixture(%{
        "system_id" => system.id,
        "position" => [1_000, 1_000, 0],
        "velocity" => [0, 0, 0]
      })

    command =
      command_fixture(%{
        "command_type" => ShipTransferToSystemObjectCommand.name(),
        "subject_type" => "ship",
        "subject_id" => ship.id,
        "ordering" => 0,
        "team_id" => team.id,
        "user_id" => user.id,
        "contents" => %{
          "system_object_id" => system_object.id,
          "orbit_distance" => 100
        }
      })

    {:ok,
     universe: universe,
     ship: ship,
     system_object: system_object,
     ship_type: ship_type,
     command: command}
  end

  test "perform transfer - 100 orbit distance", %{
    ship: ship,
    universe: universe,
    system_object: system_object,
    command: command
  } do
    assert ship.velocity == [0, 0, 0]
    assert ship.position == [0, 0, 0]
    assert ship.universe_id == universe.id

    [result] = tick_universe(universe.id)
    assert result.command_logs[command.id] == ["Progressed transfer of #{ship.id}"]
    command = Player.get_command!(command.id)
    assert command.progress == 7
    assert command.outcome["transfer"]["progress"] == 100

    ship = Space.get_ship!(ship.id)
    assert ship.velocity == [71, 71, 0]
    assert ship.position == [71, 71, 0]

    # Now tick nine more times
    tick_universe(universe.id, 9)
    assert result.command_logs[command.id] == ["Progressed transfer of #{ship.id}"]
    command = Player.get_command!(command.id)
    assert command.progress == 70
    assert command.outcome["transfer"]["progress"] == 1000

    ship = Space.get_ship!(ship.id)
    assert ship.velocity == [71, 71, 0]
    assert ship.position == [707, 707, 0]

    # And then X more to get it 1 tick before the arrival
    tick_universe(universe.id, 3)
    assert result.command_logs[command.id] == ["Progressed transfer of #{ship.id}"]
    command = Player.get_command!(command.id)
    assert command.progress == 91
    assert command.outcome["transfer"]["progress"] == 1300

    ship = Space.get_ship!(ship.id)
    assert ship.velocity == [70, 70, 0]
    assert ship.position == [919, 919, 0]

    # Now with that one extra tick, should be on the final stage of transfer
    [result] = tick_universe(universe.id)
    assert result.command_logs[command.id] == ["Nearly completed transfer of #{ship.id}"]

    command = Player.get_command!(command.id)
    assert command.progress == 99
    assert command.outcome["transfer"]["progress"] == 1414

    ship = Space.get_ship!(ship.id)
    assert ship.velocity == [10, 10, 0]
    assert ship.position == [929, 929, 0]

    # One more tick to kill the command and velocity
    [result] = tick_universe(universe.id)
    assert result.command_logs[command.id] == ["Completed transfer of #{ship.id}"]

    command = Player.get_command!(command.id)
    assert command.progress == 100
    ship = Space.get_ship!(ship.id)
    assert ship.velocity == [0, 0, 0]
    assert ship.position == [934, 925, 0]
    assert ship.orbiting_id == system_object.id

    # At this stage the ship should have no commands
    ship_command = Player.current_command_for_subject(ship.id)
    assert ship_command == nil
  end

  test "perform transfer - no orbit distance", %{
    ship: ship,
    universe: universe,
    command: command
  } do
    new_contents = Map.put(command.contents, "orbit_distance", 0)
    {:ok, _command} = Player.update_command(command, %{contents: new_contents})

    assert ship.velocity == [0, 0, 0]
    assert ship.position == [0, 0, 0]
    assert ship.universe_id == universe.id

    [result] = tick_universe(universe.id)
    assert result.command_logs[command.id] == ["Progressed transfer of #{ship.id}"]
    command = Player.get_command!(command.id)
    assert command.progress == 7
    assert command.outcome["transfer"]["progress"] == 100

    ship = Space.get_ship!(ship.id)
    assert ship.velocity == [71, 71, 0]
    assert ship.position == [71, 71, 0]

    # Now tick nine more times
    tick_universe(universe.id, 9)
    assert result.command_logs[command.id] == ["Progressed transfer of #{ship.id}"]
    command = Player.get_command!(command.id)
    assert command.progress == 70
    assert command.outcome["transfer"]["progress"] == 1000

    ship = Space.get_ship!(ship.id)
    assert ship.velocity == [71, 71, 0]
    assert ship.position == [707, 707, 0]

    # And then X more to get it 1 tick before the arrival
    tick_universe(universe.id, 4)
    assert result.command_logs[command.id] == ["Progressed transfer of #{ship.id}"]
    command = Player.get_command!(command.id)
    assert command.progress == 99
    assert command.outcome["transfer"]["progress"] == 1400

    ship = Space.get_ship!(ship.id)
    assert ship.velocity == [71, 71, 0]
    assert ship.position == [990, 990, 0]

    # Now with that one extra tick, should be on the final stage of transfer
    [result] = tick_universe(universe.id)
    assert result.command_logs[command.id] == ["Nearly completed transfer of #{ship.id}"]

    command = Player.get_command!(command.id)
    assert command.progress == 99
    assert command.outcome["transfer"]["progress"] == 1414

    ship = Space.get_ship!(ship.id)
    assert ship.velocity == [10, 10, 0]
    assert ship.position == [1_000, 1_000, 0]

    # One more tick to kill the command and velocity
    [result] = tick_universe(universe.id)
    assert result.command_logs[command.id] == ["Completed transfer of #{ship.id}"]

    command = Player.get_command!(command.id)
    assert command.progress == 100
    ship = Space.get_ship!(ship.id)
    assert ship.velocity == [0, 0, 0]
    assert ship.position == [1_000, 1_000, 0]

    # At this stage the ship should have no commands
    ship_command = Player.current_command_for_subject(ship.id)
    assert ship_command == nil
  end
end
