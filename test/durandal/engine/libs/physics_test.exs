defmodule Durandal.Engine.PhysicsTest do
  use ExUnit.Case
  alias Durandal.Engine.Physics
  import Durandal.Engine.Maths, only: [deg2rad: 1, round: 2, distance: 2, add_vector: 2]

  @pi :math.pi()

  test "apply acceleration" do
    values = [
      # Moving in 2D space (so fyz is level)
      {[0, 0], [0, -1, 0]},
      {[90, 0], [1, 0, 0]},
      {[180, 0], [0, 1, 0]},
      {[270, 0], [-1, 0, 0]},
      {[45, 0], [0.7071, -0.7071, 0]},
      {[135, 0], [0.7071, 0.7071, 0]},
      {[225, 0], [-0.7071, 0.7071, 0]},
      {[315, 0], [-0.7071, -0.7071, 0]},

      # Specific regression tests
      {[101, 0], [0.9816, 0.1908, 0]},
      {[281, 0], [-0.9816, -0.1908, 0]},
      # Because this is vertically flipped it means the x and y are different
      # {[281,  180],  [-0.9816, -0.1908, 0]},

      # Moving purely in fyz space, we are pointing directly upwards
      {[0, 270], [0, 0, -1]},
      {[90, 270], [0, 0, -1]},
      {[180, 270], [0, 0, -1]},
      {[270, 270], [0, 0, -1]},

      # Moving purely in fyz space, we are pointing directly downwards
      {[0, 90], [0, 0, 1]},
      {[90, 90], [0, 0, 1]},
      {[180, 90], [0, 0, 1]},
      {[270, 90], [0, 0, 1]}
    ]

    for {facing, expected} <- values do
      result =
        Physics.apply_acceleration(deg2rad(facing), 1)
        |> round(4)

      assert result == expected,
        message:
          "Error with #{inspect(facing)}, expected #{inspect(expected)} but got #{inspect(result)}"
    end
  end

  test "steer" do
    values = [
      # Wants to change but not allowed to
      {[100, 0, 0], [0, 0], 0, [100, 0, 0]},

      # Allowed to change as much as it wants
      {[100, 0, 0], [0, 0], 360, [0, -100, 0]},

      # Allowed to change up to 45 degrees
      {[100, 0, 0], [0, 0], 45, [70.7107, -70.7107, 0]},

      # Allowed to change up to 90 degrees, want to turn across the 0/360 mark
      {[100, -100, 0], [315, 0], 90, [-100, -100, 0]},

      # Needs to go opposite direction, can only change 90 degrees
      {[100, 100, 0], [315, 0], 90, [100, -100, 0]},

      # Needs to go opposite direction, no limit
      {[100, 100, 0], [315, 0], 360, [-100, -100, 0]}
    ]

    for {velocity, target_heading, amount, expected} <- values do
      result =
        Physics.steer(velocity, deg2rad(target_heading), deg2rad(amount))
        |> round(4)

      assert result == expected,
        message:
          "Error with #{Kernel.inspect(velocity)}, #{Kernel.inspect(target_heading)}, #{amount}, expected #{Kernel.inspect(expected)} but got #{Kernel.inspect(result)}"
    end
  end

  test "suvat_travel_time" do
    values = [
      {100, 10, 10},
      {200, 10, 20},
      {400, 20, 20}
    ]

    for {velocity, acceleration, expected} <- values do
      result = Physics.suvat_travel_time(velocity, acceleration)

      assert result == expected,
        message: "Error with #{velocity}, #{acceleration}, expected #{expected} but got #{result}"
    end
  end

  test "suvat_travel_distance" do
    values = [
      {100, 10, 5000},
      {200, 20, 40000},
      {10, 20, 2000}
    ]

    for {acceleration, time, expected} <- values do
      result = Physics.suvat_travel_distance(acceleration, time)

      assert result == expected,
        message: "Error with #{acceleration}, #{time}, expected #{expected} but got #{result}"
    end
  end

  test "decelerate?" do
    values = [
      {[0, 0, 0], [100, 0, 0], 10, [200, 0, 0], true},
      {[0, 0, 0], [100, 0, 0], 10, [1000, 0, 0], false},

      # Coming in hot, we want to start slowing down a bit here
      {[18_000, 534_000, 0], [-216, 2601, 0], 50, [20_000, 600_000, 0], true},

      # Overshot
      {[34_020, 407_600, 0], [-215, 2550, 0], 50, [20_000, 550_000, 0], false}
    ]

    for {position, velocity, acceleration, target, expected} <- values do
      result = Physics.decelerate?(position, velocity, acceleration, target)

      assert result == expected,
        message:
          "Error with #{Kernel.inspect(position)}, #{Kernel.inspect(velocity)}, #{acceleration}, #{Kernel.inspect(target)}, expected #{expected} but got #{result}"
    end
  end

  test "rotate_about_point_to_new_position" do
    values = [
      # @pi would result in a 180 rotation
      {[1_000_000, 0, 0], [0, 0, 0], @pi, [-1_000_000, 0, 0]},

      # Ensure it works when not rotating about 0,0,0, we get the same result
      # as above as it's a translation
      {[2_000_000, 0, 0], [1_000_000, 0, 0], @pi, [0, 0, 0]},

      # @pi/2 would result in a 90 rotation
      {[1_000_000, 0, 0], [0, 0, 0], @pi / 2, [0, 1_000_000, 0]},
      {[1_000_000, 0, 0], [0, 0, 0], -@pi / 2, [0, -1_000_000, 0]},

      # Small rotation amounts (360 degrees divided by the period steps)
      {[1_000_000, 0, 0], [0, 0, 0], @pi * 2 / 1000, [999_980, 6283, 0]}
    ]

    for {object_position, central_point, arc_size, expected} <- values do
      result =
        Physics.rotate_about_point_to_new_position(object_position, central_point, arc_size)
        |> Enum.map(&round/1)

      assert result == expected,
        message:
          "Error with #{Kernel.inspect(object_position)}, #{Kernel.inspect(central_point)}, #{arc_size}, expected #{inspect(expected)} but got #{inspect(result)}"
    end

    # Now ensure distances remain within tolerance, even for very small orbit speeds
    result = Physics.rotate_about_point_to_new_position([1_000_000, 0, 0], [0, 0, 0], @pi / 1000)
    assert distance(result, [0, 0, 0]) == 1_000_000

    result = Physics.rotate_about_point_to_new_position([1_000_000, 0, 0], [0, 0, 0], @pi / 3600)
    assert distance(result, [0, 0, 0]) == 1_000_000
  end

  test "calculate_orbit_translation" do
    values = [
      # @pi would result in a 180 rotation
      {[1_000_000, 0, 0], [0, 0, 0], @pi, [-2_000_000, 0, 0]},

      # Ensure it works when not rotating about 0,0,0, we get the same result
      # as above as it's a translation
      {[2_000_000, 0, 0], [1_000_000, 0, 0], @pi, [-2_000_000, 0, 0]},

      # @pi/2 would result in a 90 rotation
      {[1_000_000, 0, 0], [0, 0, 0], @pi / 2, [-1_000_000, 1_000_000, 0]},
      {[1_000_000, 0, 0], [0, 0, 0], -@pi / 2, [-1_000_000, -1_000_000, 0]},

      # Small rotation amounts (360 degrees divided by the period steps)
      {[1_000_000, 0, 0], [0, 0, 0], @pi * 2 / 1000, [-20, 6283, 0]}
    ]

    for {object_position, central_point, arc_size, expected} <- values do
      result =
        Physics.calculate_orbit_translation(object_position, central_point, arc_size)
        |> Enum.map(&round/1)

      assert result == expected,
        message:
          "Error with #{Kernel.inspect(object_position)}, #{Kernel.inspect(central_point)}, #{arc_size}, expected #{inspect(expected)} but got #{inspect(result)}"
    end

    # Now ensure distances remain within tolerance, even for very small orbit speeds
    result =
      Physics.calculate_orbit_translation([1_000_000, 0, 0], [0, 0, 0], @pi / 1000)
      |> add_vector([1_000_000, 0, 0])

    assert distance(result, [0, 0, 0]) == 1_000_000

    result =
      Physics.calculate_orbit_translation([1_000_000, 0, 0], [0, 0, 0], @pi / 3600)
      |> add_vector([1_000_000, 0, 0])

    assert distance(result, [0, 0, 0]) == 1_000_000
  end
end
