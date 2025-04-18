defmodule Durandal.Engine.Commands.StationTransferToStationCommandTest do
  use Durandal.SimCase
  alias Durandal.Engine.StationTransferToStationCommand
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

    station =
      station_fixture(%{
        "system_id" => system.id,
        "team_id" => team.id,
        "position" => [0, 0, 0],
        "velocity" => [0, 0, 0]
      })

    target_station =
      station_fixture(%{
        "system_id" => system.id,
        "team_id" => team.id,
        "position" => [1_000, 1_000, 0],
        "velocity" => [0, 0, 0]
      })

    command =
      command_fixture(%{
        "command_type" => StationTransferToStationCommand.name(),
        "subject_type" => "station",
        "subject_id" => station.id,
        "ordering" => 0,
        "team_id" => team.id,
        "user_id" => user.id,
        "contents" => %{
          "station_id" => target_station.id
        }
      })

    {:ok, universe: universe, station: station, target_station: target_station, command: command}
  end

  test "perform transfer", %{station: station, universe: universe} do
    assert station.velocity == [0, 0, 0]
    assert station.position == [0, 0, 0]
    assert station.universe_id == universe.id
    assert station.current_transfer_id == nil

    [result] = tick_universe(universe.id)

    assert result.systems_logs["Transfer"][:stations] == %{progress: [station.id]}

    station = Space.get_station!(station.id, preload: [:transfer])
    assert station.velocity == [0, 0, 0]
    assert station.position == [71, 71, 0]
    refute station.current_transfer_id == nil
    assert station.current_transfer.progress == Space.StationLib.station_acceleration()
    assert round(station.current_transfer.progress_percentage) == 7

    # Now tick nine more times
    tick_universe(universe.id, 9)

    station = Space.get_station!(station.id, preload: [:transfer])
    assert station.velocity == [0, 0, 0]
    assert station.position == [707, 707, 0]
    refute station.current_transfer_id == nil
    assert station.current_transfer.progress == Space.StationLib.station_acceleration() * 10
    assert round(station.current_transfer.progress_percentage) == 71

    # And then X more to get it 1 tick before the arrival
    tick_universe(universe.id, 4)

    station = Space.get_station!(station.id, preload: [:transfer])
    assert station.velocity == [0, 0, 0]
    assert station.position == [990, 990, 0]
    refute station.current_transfer_id == nil
    assert_in_delta(station.current_transfer.progress_percentage, 99, 0.1)

    # Now with that one extra tick, should no longer be transferring
    [result] = tick_universe(universe.id)

    assert result.systems_logs["Transfer"][:stations] == %{complete: [station.id]}

    station = Space.get_station!(station.id, preload: [:transfer, :incomplete_commands])
    assert station.velocity == [0, 0, 0]
    assert station.position == [1_000, 1_000, 0]
    assert station.current_transfer_id == nil

    # At this stage the station should have no commands
    assert Enum.empty?(station.commands)

    # Tick again, we expect no transfers
    [result] = tick_universe(universe.id)
    assert result.systems_logs["Transfer"][:stations] == %{}
  end
end
