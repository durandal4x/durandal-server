defmodule Durandal.Engine.Commands.ShipTransferToStationCommandTest do
  use Durandal.SimCase
  alias Durandal.Engine.ShipTransferToStationCommand
  alias Durandal.Space

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

    station =
      station_fixture(%{
        "system_id" => system.id,
        "team_id" => team.id,
        "position" => [1_000, 1_000, 0],
        "velocity" => [0, 0, 0]
      })

    command =
      command_fixture(%{
        "command_type" => ShipTransferToStationCommand.name(),
        "subject_type" => "ship",
        "subject_id" => ship.id,
        "ordering" => 0,
        "team_id" => team.id,
        "user_id" => user.id,
        "contents" => %{
          "station_id" => station.id
        }
      })

    {:ok,
     universe: universe, ship: ship, station: station, ship_type: ship_type, command: command}
  end

  test "perform transfer", %{ship: ship, universe: universe, ship_type: ship_type} do
    assert ship.velocity == [0, 0, 0]
    assert ship.position == [0, 0, 0]
    assert ship.universe_id == universe.id
    assert ship.current_transfer_id == nil

    [result] = tick_universe(universe.id)

    assert result.systems_logs["Transfer"] == %{
             ships: %{progress: [ship.id]}
           }

    ship = Space.get_ship!(ship.id, preload: [:transfer])
    assert ship.velocity == [0, 0, 0]
    assert ship.position == [71, 71, 0]
    refute ship.current_transfer_id == nil
    assert ship.current_transfer.progress == ship_type.acceleration
    assert round(ship.current_transfer.progress_percentage) == 7

    # Now tick nine more times
    tick_universe(universe.id, 9)

    ship = Space.get_ship!(ship.id, preload: [:transfer])
    assert ship.velocity == [0, 0, 0]
    assert ship.position == [707, 707, 0]
    refute ship.current_transfer_id == nil
    assert ship.current_transfer.progress == ship_type.acceleration * 10
    assert round(ship.current_transfer.progress_percentage) == 71

    # And then X more to get it 1 tick before the arrival
    tick_universe(universe.id, 4)

    ship = Space.get_ship!(ship.id, preload: [:transfer])
    assert ship.velocity == [0, 0, 0]
    assert ship.position == [990, 990, 0]
    refute ship.current_transfer_id == nil
    assert_in_delta(ship.current_transfer.progress_percentage, 99, 0.1)

    # Now with that one extra tick, should no longer be transferring
    [result] = tick_universe(universe.id)

    assert result.systems_logs["Transfer"] == %{
             ships: %{complete: [ship.id]}
           }

    ship = Space.get_ship!(ship.id, preload: [:transfer, :incomplete_commands])
    assert ship.velocity == [0, 0, 0]
    assert ship.position == [1_000, 1_000, 0]
    assert ship.current_transfer_id == nil

    # At this stage the ship should have no commands
    assert Enum.empty?(ship.commands)

    # Tick again, we expect no transfers
    [result] = tick_universe(universe.id)
    assert result.systems_logs["Transfer"] == %{ships: %{}}
  end
end
