defmodule Durandal.Engine.Sims.OrbitSimTest do
  use Durandal.SimCase
  alias Durandal.Space
  alias Durandal.Engine.Maths

  test "basic orbital test" do
    universe = start_universe("basic_orbit", [])

    pid = Durandal.Game.UniverseLib.get_game_supervisor_pid(universe.id)
    assert is_pid(pid)

    objects =
      Space.list_system_objects(where: [universe_id: universe.id])
      |> Map.new(fn so ->
        {so.name, so}
      end)

    # Check locations
    assert objects["planet1"].position == [1_000_000, 0, 0]
    assert objects["planet2"].position == [1_000_000, 0, 0]

    # Distances
    assert objects["star"].position
           |> Maths.distance(objects["planet1"].position) == 1_000_000

    assert objects["star"].position
           |> Maths.distance(objects["planet2"].position) == 1_000_000

    # Directions
    assert objects["star"].position
           |> Maths.calculate_angle(objects["planet1"].position)
           |> Maths.rad2deg() == [90, 0]

    assert objects["star"].position
           |> Maths.calculate_angle(objects["planet2"].position)
           |> Maths.rad2deg() == [90, 0]

    # Tick once
    tick_universe(universe.id)

    objects =
      Space.list_system_objects(where: [universe_id: universe.id])
      |> Map.new(fn so ->
        {so.name, so}
      end)

    # Check locations have changed
    assert objects["planet1"].position != [1_000_000, 0, 0]
    assert objects["planet2"].position != [1_000_000, 0, 0]

    # Distances
    assert_in_delta objects["star"].position
                    |> Maths.distance(objects["planet1"].position),
                    1_000_000,
                    3

    assert_in_delta objects["star"].position
                    |> Maths.distance(objects["planet2"].position),
                    1_000_000,
                    3

    # Directions
    assert objects["star"].position
           |> Maths.calculate_angle(objects["planet1"].position)
           |> Maths.rad2deg()
           |> Maths.round_list() == [90, 0]

    assert objects["star"].position
           |> Maths.calculate_angle(objects["planet2"].position)
           |> Maths.rad2deg()
           |> Maths.round_list() == [91, 0]

    # Now we want to tick a bunch of times, where do we end up?
    # after this command we'll have executed 100 ticks
    tick_universe(universe.id, 99)

    objects =
      Space.list_system_objects(where: [universe_id: universe.id])
      |> Map.new(fn so ->
        {so.name, so}
      end)

    # Distances, after 100 ticks we accept there will be some errors
    assert_in_delta objects["star"].position
                    |> Maths.distance(objects["planet1"].position),
                    1_000_000,
                    5

    assert_in_delta objects["star"].position
                    |> Maths.distance(objects["planet2"].position),
                    1_000_000,
                    5

    # Directions
    assert objects["star"].position
           |> Maths.calculate_angle(objects["planet1"].position)
           |> Maths.rad2deg()
           |> Maths.round_list() == [100, 0]

    assert objects["star"].position
           |> Maths.calculate_angle(objects["planet2"].position)
           |> Maths.rad2deg()
           |> Maths.round_list() == [190, 0]

    # Now we tick a few more times, after 360 total ticks planet2 should be back to
    # the start spot (roughly)
    tick_universe(universe.id, 260)

    objects =
      Space.list_system_objects(where: [universe_id: universe.id])
      |> Map.new(fn so ->
        {so.name, so}
      end)

    # Distances, after 100 ticks we accept there will be some errors
    assert_in_delta objects["star"].position
                    |> Maths.distance(objects["planet1"].position),
                    1_000_000,
                    5

    assert_in_delta objects["star"].position
                    |> Maths.distance(objects["planet2"].position),
                    1_000_000,
                    5

    # Directions
    assert objects["star"].position
           |> Maths.calculate_angle(objects["planet1"].position)
           |> Maths.rad2deg()
           |> Maths.round_list() == [126, 0]

    assert objects["star"].position
           |> Maths.calculate_angle(objects["planet2"].position)
           |> Maths.rad2deg()
           |> Maths.round_list() == [90, 0]

    tear_down(universe.id)
  end

  test "complex orbital test" do
    universe = start_universe("complex_orbit", [])

    pid = Durandal.Game.UniverseLib.get_game_supervisor_pid(universe.id)
    assert is_pid(pid)

    objects =
      Space.list_system_objects(where: [universe_id: universe.id])
      |> Map.new(fn so ->
        {so.name, so}
      end)

    # Check locations
    assert objects["planet1"].position == [1_000_000, 0, 0]
    assert objects["planet2"].position == [2_000_000, 0, 0]
    assert objects["planet3a"].position == [2_100_000, 0, 0]

    # Distances
    assert objects["star"].position
           |> Maths.distance(objects["planet1"].position) == 1_000_000

    assert objects["planet1"].position
           |> Maths.distance(objects["planet2"].position) == 1_000_000

    assert objects["planet2"].position
           |> Maths.distance(objects["planet3a"].position) == 100_000

    assert objects["planet2"].position
           |> Maths.distance(objects["planet3b"].position) == 100_000

    # Directions
    assert objects["star"].position
           |> Maths.calculate_angle(objects["planet1"].position)
           |> Maths.rad2deg() == [90, 0]

    assert objects["planet1"].position
           |> Maths.calculate_angle(objects["planet2"].position)
           |> Maths.rad2deg() == [90, 0]

    assert objects["planet2"].position
           |> Maths.calculate_angle(objects["planet3a"].position)
           |> Maths.rad2deg() == [90, 0]

    assert objects["planet2"].position
           |> Maths.calculate_angle(objects["planet3b"].position)
           |> Maths.rad2deg() == [270, 0]

    # Tick once
    tick_universe(universe.id)

    objects =
      Space.list_system_objects(where: [universe_id: universe.id])
      |> Map.new(fn so ->
        {so.name, so}
      end)

    # Check locations have changed
    assert objects["planet1"].position != [1_000_000, 0, 0]
    assert objects["planet2"].position != [2_000_000, 0, 0]
    assert objects["planet3a"].position != [2_100_000, 0, 0]
    assert objects["planet3b"].position != [1_900_000, 0, 0]

    # Distances
    assert_in_delta(
      Maths.distance(objects["star"].position, objects["planet1"].position),
      1_000_000,
      3
    )

    assert_in_delta(
      Maths.distance(objects["planet1"].position, objects["planet2"].position),
      1_000_000,
      3
    )

    assert_in_delta(
      Maths.distance(objects["planet2"].position, objects["planet3a"].position),
      100_000,
      3
    )

    assert_in_delta(
      Maths.distance(objects["planet2"].position, objects["planet3b"].position),
      100_000,
      3
    )

    # Directions
    assert objects["star"].position
           |> Maths.calculate_angle(objects["planet1"].position)
           |> Maths.rad2deg()
           |> Maths.round_list() == [90, 0]

    assert objects["planet1"].position
           |> Maths.calculate_angle(objects["planet2"].position)
           |> Maths.rad2deg()
           |> Maths.round_list() == [91, 0]

    assert objects["planet2"].position
           |> Maths.calculate_angle(objects["planet3a"].position)
           |> Maths.rad2deg()
           |> Maths.round_list() == [94, 0]

    assert objects["planet2"].position
           |> Maths.calculate_angle(objects["planet3b"].position)
           |> Maths.rad2deg()
           |> Maths.round_list() == [274, 0]

    # # Now we want to tick a bunch of times, where do we end up?
    # # after this command we'll have executed 100 ticks
    # tick_universe(universe.id, 99)

    # objects = Space.list_system_objects(where: [universe_id: universe.id])
    # |> Map.new(fn so ->
    #   {so.name, so}
    # end)

    # # Distances, after 100 ticks we accept there will be some errors
    # assert_in_delta objects["star"].position
    #   |> Maths.distance(objects["planet1"].position), 10000, 5
    # assert_in_delta objects["star"].position
    #   |> Maths.distance(objects["planet2"].position), 10000, 5

    # # Directions
    # assert objects["star"].position
    #   |> Maths.calculate_angle(objects["planet1"].position)
    #   |> Maths.rad2deg()
    #   |> Maths.round_list == [100, 0]

    # assert objects["star"].position
    #   |> Maths.calculate_angle(objects["planet2"].position)
    #   |> Maths.rad2deg()
    #   |> Maths.round_list == [190, 0]

    # # Now we tick a few more times, after 360 total ticks planet2 should be back to
    # # the start spot (roughly)
    # tick_universe(universe.id, 260)

    # objects = Space.list_system_objects(where: [universe_id: universe.id])
    # |> Map.new(fn so ->
    #   {so.name, so}
    # end)

    # # Distances, after 100 ticks we accept there will be some errors
    # assert_in_delta objects["star"].position
    #   |> Maths.distance(objects["planet1"].position), 10000, 5
    # assert_in_delta objects["star"].position
    #   |> Maths.distance(objects["planet2"].position), 10000, 5

    # # Directions
    # assert objects["star"].position
    #   |> Maths.calculate_angle(objects["planet1"].position)
    #   |> Maths.rad2deg()
    #   |> Maths.round_list == [126, 0]

    # assert objects["star"].position
    #   |> Maths.calculate_angle(objects["planet2"].position)
    #   |> Maths.rad2deg()
    #   |> Maths.round_list == [90, 0]

    tear_down(universe.id)
  end
end
