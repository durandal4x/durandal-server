defmodule Durandal.Engine.Commands.ShipLoadCargoCommandTest do
  use Durandal.SimCase
  alias Durandal.Engine.ShipLoadCargoCommand
  alias Durandal.{Space, Player, Resources}

  setup _tags do
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
        "position" => [1_000, 1_000, 0],
        "velocity" => [0, 0, 0]
      })

    station_module =
      station_module_fixture(%{
        "station_id" => station.id
      })

    ship_type =
      ship_type_fixture(%{
        "universe_id" => universe.id
      })

    ship =
      ship_fixture(%{
        "system_id" => system.id,
        "team_id" => team.id,
        "type_id" => ship_type.id,
        "position" => [0, 0, 0],
        "velocity" => [0, 0, 0],
        "docked_with_id" => station.id
      })

    simple_type1 = simple_type_fixture()
    simple_type2 = simple_type_fixture()
    simple_type3 = simple_type_fixture()

    simple_cargo1 =
      simple_station_module_instance_fixture(%{
        "station_module_id" => station_module.id,
        "type_id" => simple_type1.id,
        "quantity" => 1000
      })

    simple_cargo2 =
      simple_station_module_instance_fixture(%{
        "station_module_id" => station_module.id,
        "type_id" => simple_type2.id,
        "quantity" => 1000
      })

    composite_type1 = composite_type_fixture(%{"contents" => [simple_type1.id, simple_type2.id]})

    composite_type2 =
      composite_type_fixture(%{"contents" => [simple_type1.id, simple_type2.id, simple_type3.id]})

    composite_cargo1 =
      composite_station_module_instance_fixture(%{
        "station_module_id" => station_module.id,
        "type_id" => composite_type1.id,
        "quantity" => 1000,
        "ratios" => [50, 50]
      })

    composite_cargo2 =
      composite_station_module_instance_fixture(%{
        "station_module_id" => station_module.id,
        "type_id" => composite_type2.id,
        "quantity" => 1000,
        "ratios" => [400, 400, 1]
      })

    resources_to_transfer = [
      [simple_cargo1.type_id, 40],
      [simple_cargo2.type_id, 40],
      [composite_cargo1.type_id, 40],
      [composite_cargo2.type_id, 40]
    ]

    contents =
      ShipLoadCargoCommand.parse(%{
        "resources" => resources_to_transfer,
        "target_id" => station_module.id
      })

    command =
      command_fixture(%{
        "command_type" => ShipLoadCargoCommand.name(),
        "subject_type" => "ship",
        "subject_id" => ship.id,
        "ordering" => 0,
        "team_id" => team.id,
        "user_id" => user.id,
        "contents" => contents
      })

    {:ok,
     universe: universe,
     ship: ship,
     station: station,
     command: command,
     station_module: station_module,
     simple_type1: simple_type1,
     simple_type2: simple_type2,
     simple_type3: simple_type3,
     composite_type1: composite_type1,
     composite_type2: composite_type2}
  end

  test "not docked", %{
    universe: universe,
    command: command,
    ship: ship
  } do
    {:ok, ship} = Space.update_ship(ship, %{docked_with_id: nil})
    [result] = tick_universe(universe.id)

    [log] = result.command_logs[command.id]
    assert log == "Cancelled #{ship.id} load command as not docked with a station"
  end

  test "load stuff - lots of cargo", %{
    universe: universe,
    ship: ship,
    station: station,
    station_module: station_module,
    command: command,
    simple_type1: simple_type1,
    simple_type2: simple_type2,
    composite_type1: composite_type1,
    composite_type2: composite_type2
  } do
    combined_station_cargo =
      Resources.list_all_station_resources(station.id)
      |> Tuple.to_list()
      |> List.flatten()
      |> Map.new(fn i -> {i.type_id, i.quantity} end)

    assert Map.values(combined_station_cargo) |> Enum.sum() == 4000

    combined_ship_cargo =
      [
        Resources.list_simple_ship_instances(where: [ship_id: ship.id]),
        Resources.list_composite_ship_instances(where: [ship_id: ship.id])
      ]
      |> List.flatten()
      |> Map.new(fn i -> {i.type_id, i.quantity} end)

    assert Map.values(combined_ship_cargo) |> Enum.sum() == 0

    # ------------------------ Tick 0
    [result] = tick_universe(universe.id)

    assert result.command_logs[command.id] == [
             "Transferred 40 cargo from station #{station.id}, module #{station_module.id} to ship #{ship.id}"
           ]

    # Now, ensure the resources have moved the way we expect
    combined_station_module_cargo =
      [
        Resources.list_simple_station_module_instances(
          where: [station_module_id: station_module.id]
        ),
        Resources.list_composite_station_module_instances(
          where: [station_module_id: station_module.id]
        )
      ]
      |> List.flatten()
      |> Map.new(fn i -> {i.type_id, i.quantity} end)

    assert combined_station_module_cargo == %{
             simple_type1.id => 960,
             simple_type2.id => 1000,
             composite_type1.id => 1000,
             composite_type2.id => 1000
           }

    combined_ship_cargo =
      [
        Resources.list_simple_ship_instances(where: [ship_id: ship.id]),
        Resources.list_composite_ship_instances(where: [ship_id: ship.id])
      ]
      |> List.flatten()
      |> Map.new(fn i -> {i.type_id, i.quantity} end)

    assert combined_ship_cargo == %{
             simple_type1.id => 40
           }

    command = Player.get_command(command.id)

    assert command.outcome == %{
             "remaining" => [
               [simple_type1.id, 0],
               [simple_type2.id, 40],
               [composite_type1.id, 40],
               [composite_type2.id, 40]
             ],
             "start_tick" => 0,
             "transferred" => %{
               simple_type1.id => 40
             },
             "total_to_transfer" => 160
           }

    # Command should be incomplete
    assert command.progress == 25

    # ------------------------ Tick 1-3
    [_, _, result] = tick_universe(universe.id, 3)

    assert result.command_logs[command.id] == [
             "Completed cargo transfer from station #{station.id} to ship #{ship.id}"
           ]

    # Now, ensure the resources have moved the way we expect
    combined_station_module_cargo =
      [
        Resources.list_simple_station_module_instances(
          where: [station_module_id: station_module.id]
        ),
        Resources.list_composite_station_module_instances(
          where: [station_module_id: station_module.id]
        )
      ]
      |> List.flatten()
      |> Map.new(fn i -> {i.type_id, i.quantity} end)

    assert combined_station_module_cargo == %{
             simple_type1.id => 960,
             simple_type2.id => 960,
             composite_type1.id => 960,
             composite_type2.id => 960
           }

    combined_ship_cargo =
      [
        Resources.list_simple_ship_instances(where: [ship_id: ship.id]),
        Resources.list_composite_ship_instances(where: [ship_id: ship.id])
      ]
      |> List.flatten()
      |> Map.new(fn i -> {i.type_id, i.quantity} end)

    assert combined_ship_cargo == %{
             simple_type1.id => 40,
             simple_type2.id => 40,
             composite_type1.id => 40,
             composite_type2.id => 40
           }

    command = Player.get_command(command.id)

    assert command.outcome == %{
             "remaining" => [
               [simple_type1.id, 0],
               [simple_type2.id, 0],
               [composite_type1.id, 0],
               [composite_type2.id, 0]
             ],
             "start_tick" => 0,
             "transferred" => %{
               simple_type1.id => 40,
               simple_type2.id => 40,
               composite_type1.id => 40,
               composite_type2.id => 40
             },
             "total_to_transfer" => 160,
             "stop_tick" => 3
           }

    # Command should be complete
    assert command.progress == 100

    # ------------------------ Tick 4 (expected no change)
    [result] = tick_universe(universe.id)
    refute Map.has_key?(result.command_logs, command.id)

    # Now, ensure the resources have moved the way we expect
    combined_ship_cargo =
      [
        Resources.list_simple_ship_instances(where: [ship_id: ship.id]),
        Resources.list_composite_ship_instances(where: [ship_id: ship.id])
      ]
      |> List.flatten()
      |> Map.new(fn i -> {i.type_id, i.quantity} end)

    # Assert nothing else happened regarding cargo transfer
    assert combined_ship_cargo == %{
             simple_type1.id => 40,
             simple_type2.id => 40,
             composite_type1.id => 40,
             composite_type2.id => 40
           }

    combined_station_module_cargo =
      [
        Resources.list_simple_station_module_instances(
          where: [station_module_id: station_module.id]
        ),
        Resources.list_composite_station_module_instances(
          where: [station_module_id: station_module.id]
        )
      ]
      |> List.flatten()
      |> Map.new(fn i -> {i.type_id, i.quantity} end)

    assert combined_station_module_cargo == %{
             simple_type1.id => 960,
             simple_type2.id => 960,
             composite_type1.id => 960,
             composite_type2.id => 960
           }
  end

  test "load stuff without enough cargo present", %{
    universe: universe,
    ship: ship,
    station: station,
    station_module: station_module,
    command: command,
    simple_type1: simple_type1,
    simple_type2: simple_type2,
    composite_type1: composite_type1,
    composite_type2: composite_type2
  } do
    Resources.list_simple_station_module_instances(where: [station_module_id: station_module.id])
    |> Enum.each(fn i ->
      Resources.update_simple_station_module_instance(i, %{quantity: 10})
    end)

    Resources.list_composite_station_module_instances(
      where: [station_module_id: station_module.id]
    )
    |> Enum.each(fn i ->
      Resources.update_composite_station_module_instance(i, %{quantity: 10})
    end)

    combined_station_cargo =
      Resources.list_all_station_resources(station.id)
      |> Tuple.to_list()
      |> List.flatten()
      |> Map.new(fn i -> {i.type_id, i.quantity} end)

    assert Map.values(combined_station_cargo) |> Enum.sum() == 40

    combined_ship_cargo =
      [
        Resources.list_simple_ship_instances(where: [ship_id: ship.id]),
        Resources.list_composite_ship_instances(where: [ship_id: ship.id])
      ]
      |> List.flatten()
      |> Map.new(fn i -> {i.type_id, i.quantity} end)

    assert Map.values(combined_ship_cargo) |> Enum.sum() == 0

    # ------------------------ Tick 1
    [result] = tick_universe(universe.id)

    assert result.command_logs[command.id] == [
             "Transferred 10 cargo from station #{station.id}, module #{station_module.id} to ship #{ship.id}"
           ]

    # Now, ensure the resources have moved the way we expect
    combined_ship_cargo =
      [
        Resources.list_simple_ship_instances(where: [ship_id: ship.id]),
        Resources.list_composite_ship_instances(where: [ship_id: ship.id])
      ]
      |> List.flatten()
      |> Map.new(fn i -> {i.type_id, i.quantity} end)

    assert combined_ship_cargo == %{
             simple_type1.id => 10
           }

    combined_station_module_cargo =
      [
        Resources.list_simple_station_module_instances(
          where: [station_module_id: station_module.id]
        ),
        Resources.list_composite_station_module_instances(
          where: [station_module_id: station_module.id]
        )
      ]
      |> List.flatten()
      |> Map.new(fn i -> {i.type_id, i.quantity} end)

    assert combined_station_module_cargo == %{
             simple_type1.id => 0,
             simple_type2.id => 10,
             composite_type1.id => 10,
             composite_type2.id => 10
           }

    command = Player.get_command(command.id)

    assert command.outcome == %{
             "remaining" => [
               [simple_type1.id, 30],
               [simple_type2.id, 40],
               [composite_type1.id, 40],
               [composite_type2.id, 40]
             ],
             "start_tick" => 0,
             "transferred" => %{
               simple_type1.id => 10
             },
             "total_to_transfer" => 160
           }

    # Command should be incomplete
    assert command.progress == 6

    # We need to tick 3 more times to transfer partially from each of the others
    [_, _, result] = tick_universe(universe.id, 3)

    assert result.command_logs[command.id] == [
             "Transferred 10 cargo from station #{station.id}, module #{station_module.id} to ship #{ship.id}"
           ]

    # Now, ensure the resources have moved the way we expect
    combined_ship_cargo =
      [
        Resources.list_simple_ship_instances(where: [ship_id: ship.id]),
        Resources.list_composite_ship_instances(where: [ship_id: ship.id])
      ]
      |> List.flatten()
      |> Map.new(fn i -> {i.type_id, i.quantity} end)

    assert combined_ship_cargo == %{
             simple_type1.id => 10,
             simple_type2.id => 10,
             composite_type1.id => 10,
             composite_type2.id => 10
           }

    combined_station_module_cargo =
      [
        Resources.list_simple_station_module_instances(
          where: [station_module_id: station_module.id]
        ),
        Resources.list_composite_station_module_instances(
          where: [station_module_id: station_module.id]
        )
      ]
      |> List.flatten()
      |> Map.new(fn i -> {i.type_id, i.quantity} end)

    assert combined_station_module_cargo == %{
             simple_type1.id => 0,
             simple_type2.id => 0,
             composite_type1.id => 0,
             composite_type2.id => 0
           }

    command = Player.get_command(command.id)

    assert command.outcome == %{
             "remaining" => [
               [simple_type1.id, 30],
               [simple_type2.id, 30],
               [composite_type1.id, 30],
               [composite_type2.id, 30]
             ],
             "start_tick" => 0,
             "transferred" => %{
               simple_type1.id => 10,
               simple_type2.id => 10,
               composite_type1.id => 10,
               composite_type2.id => 10
             },
             "total_to_transfer" => 160
           }

    # Command should be incomplete
    assert command.progress == 25

    # Final tick, command should transfer nothing and end the command
    [result] = tick_universe(universe.id)

    assert result.command_logs[command.id] == [
             "Cancelled #{ship.id} load command as ran out of cargo to transfer"
           ]

    # Now, ensure the resources have moved the way we expect
    combined_ship_cargo =
      [
        Resources.list_simple_ship_instances(where: [ship_id: ship.id]),
        Resources.list_composite_ship_instances(where: [ship_id: ship.id])
      ]
      |> List.flatten()
      |> Map.new(fn i -> {i.type_id, i.quantity} end)

    assert combined_ship_cargo == %{
             simple_type1.id => 10,
             simple_type2.id => 10,
             composite_type1.id => 10,
             composite_type2.id => 10
           }

    combined_station_module_cargo =
      [
        Resources.list_simple_station_module_instances(
          where: [station_module_id: station_module.id]
        ),
        Resources.list_composite_station_module_instances(
          where: [station_module_id: station_module.id]
        )
      ]
      |> List.flatten()
      |> Map.new(fn i -> {i.type_id, i.quantity} end)

    assert combined_station_module_cargo == %{
             simple_type1.id => 0,
             simple_type2.id => 0,
             composite_type1.id => 0,
             composite_type2.id => 0
           }

    command = Player.get_command(command.id)

    assert command.outcome == %{
             "remaining" => [
               [simple_type1.id, 30],
               [simple_type2.id, 30],
               [composite_type1.id, 30],
               [composite_type2.id, 30]
             ],
             "start_tick" => 0,
             "stop_tick" => 4,
             "transferred" => %{
               simple_type1.id => 10,
               simple_type2.id => 10,
               composite_type1.id => 10,
               composite_type2.id => 10
             },
             "total_to_transfer" => 160
           }

    # Final tick, shouldn't do anything
    [result] = tick_universe(universe.id)
    refute Map.has_key?(result.command_logs, command.id)
  end
end
