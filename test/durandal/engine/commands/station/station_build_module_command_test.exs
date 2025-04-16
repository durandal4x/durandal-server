defmodule Durandal.Engine.Commands.StationBuildModuleCommandTest do
  use Durandal.SimCase
  alias Durandal.Engine.StationBuildModuleCommand
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

    module_type =
      station_module_type_fixture(%{
        "universe_id" => universe.id,
        "build_time" => 30
      })

    command =
      command_fixture(%{
        "command_type" => StationBuildModuleCommand.name(),
        "subject_type" => "station",
        "subject_id" => station.id,
        "ordering" => 0,
        "team_id" => team.id,
        "user_id" => user.id,
        "contents" => %{
          "module_type_id" => module_type.id
        }
      })

    {:ok, universe: universe, station: station, module_type: module_type, command: command}
  end

  test "perform transfer", %{station: station, universe: universe, command: command} do
    modules = Space.list_station_modules(where: [universe_id: universe.id])
    assert Enum.empty?(modules)

    command = Player.get_command!(command.id)
    assert command.outcome == nil

    _ = tick_universe(universe.id)

    [module] = Space.list_station_modules(where: [universe_id: universe.id])
    assert module.station_id == station.id
    assert module.build_progress == 10
    module_id = module.id

    command = Player.get_command!(command.id)
    assert command.outcome["station_module_id"] == module.id
    assert command.progress == 33

    _ = tick_universe(universe.id)

    module = Space.get_station_module!(module_id)
    assert module.build_progress == 20

    command = Player.get_command!(command.id)
    assert command.progress == 66

    _ = tick_universe(universe.id)

    module = Space.get_station_module!(module_id)
    assert module.build_progress == 30

    command = Player.get_command!(command.id)
    assert command.progress == 100

    # Ship is already complete, should have no errors etc
    _ = tick_universe(universe.id)

    module = Space.get_station_module!(module_id)
    assert module.build_progress == 30

    command = Player.get_command!(command.id)
    assert command.progress == 100
  end
end
