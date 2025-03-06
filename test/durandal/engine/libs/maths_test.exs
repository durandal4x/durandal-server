defmodule Durandal.Engine.MathsTest do
  use ExUnit.Case
  alias Durandal.Engine.Maths

  defp deg(v), do: round(Maths.rad2deg(v))

  defp round(0, _p), do: 0
  defp round(v, p), do: Float.round(v, p)

  test "invert angle" do
    values = [
      {0, 180},
      {90, 270}
    ]

    for {a1, a2} <- values do
      r1 = Maths.deg2rad(a1) |> round(4)
      r2 = Maths.deg2rad(a2) |> round(4)

      result1 =
        Maths.invert_angle(r1)
        |> round(4)

      assert r2 == result1,
        message: "Error with first conversion on #{a1},#{a2}, expected #{r2}, got #{result1}"

      result2 =
        Maths.invert_angle(r2)
        |> round(4)

      assert r1 == result2,
        message: "Error with second conversion on #{a1},#{a2}, expected #{r1}, got #{result2}"
    end
  end

  test "shortest angle" do
    values = [
      # Already the equal
      {0, 0, :equal},
      {40, 40, :equal},
      # {0, 360, :equal},

      # Standard angles, both right of 0 degrees
      {20, 30, :right},
      {20, 10, :left},

      # Both left of 0 degrees
      {340, 350, :right},
      {340, 330, :left},

      # # Straddling 0 degrees
      {340, 20, :right},
      {20, 340, :left},

      # Opposites
      {135, 315, :left},
      {0, 180, :left}
    ]

    for {a1, a2, expected} <- values do
      result = Maths.shortest_angle(Maths.deg2rad(a1), Maths.deg2rad(a2))

      assert result == expected,
        message: "Error with #{a1} -> #{a2}, expected #{expected} but got #{result}"
    end
  end

  test "angle_distance" do
    values = [
      # Already equal
      {0, 0, 0},
      {40, 40, 0},

      # Standard angles, both right of 0 degrees
      {20, 30, 10},
      {20, 10, 10},

      # Both left of 0 degrees
      {340, 350, 10},
      {340, 330, 10},

      # # Straddling 0 degrees
      {340, 20, 40}
      # {20, 340, 40},
    ]

    for {a1, a2, expected} <- values do
      result =
        Maths.angle_distance(Maths.deg2rad(a1), Maths.deg2rad(a2))
        |> round(4)

      expected =
        expected
        |> Maths.deg2rad()
        |> round(4)

      assert result == expected,
        message:
          "Error with #{a1} -> #{a2}, expected #{Maths.deg2rad(expected)} but got #{result}"

      result2 =
        Maths.angle_distance(Maths.deg2rad(a2), Maths.deg2rad(a1))
        |> round(4)

      assert result2 == expected,
        message:
          "Error with #{a1} -> #{a2} reversed, expected #{Maths.deg2rad(expected)} but got #{result2}"
    end
  end

  test "limit" do
    values2 = [
      # Too high
      {100, 50, 50},
      {100, 25, 25},

      # Too low
      {-100, 50, -50},
      {-100, 25, -25},

      # Within range
      {20, 50, 20},
      {20, 25, 20},
      {-20, 50, -20},
      {-20, 25, -20}
    ]

    for {v, b, expected} <- values2 do
      result = Maths.limit(v, b)

      assert result == expected,
        message: "Error with #{v}, #{b}; expected #{expected} but got #{result}"
    end

    values3 = [
      # Too high
      {100, -15, 50, 50},
      {100, -15, 25, 25},

      # Too low
      {-100, -15, 50, -15},
      {-100, -15, 25, -15},

      # Within range
      {20, -15, 50, 20},
      {20, -15, 25, 20},
      {-20, -50, 50, -20},
      {-20, -50, 25, -20}
    ]

    for {v, lb, ub, expected} <- values3 do
      result = Maths.limit(v, lb, ub)

      assert result == expected,
        message: "Error with #{v}, #{lb}, #{ub}; expected #{expected} but got #{result}"
    end
  end

  test "limit change" do
    values = [
      # Limit not required
      {100, 15, 20, 115},
      {100, 25, 50, 125},
      {100, -15, 20, 85},
      {100, -25, 50, 75},

      # Limit used
      {100, 100, 20, 120},
      {100, 100, 50, 150},
      {100, -100, 20, 80},
      {100, -100, 50, 50}
    ]

    for {origin, limit_amount, change, expected} <- values do
      result = Maths.limit_change(origin, limit_amount, change)

      assert result == expected,
        message:
          "Error with #{origin}, #{limit_amount}, #{change}; expected #{expected} but got #{result}"
    end
  end

  test "degrees and radians" do
    values = [
      {0, 0},
      {180, :math.pi()},
      {360, :math.pi() * 2},
      {45, :math.pi() / 4},
      {90, :math.pi() / 2}
    ]

    for {deg, rad} <- values do
      assert Maths.deg2rad(deg) == rad
      assert Maths.rad2deg(rad) == deg

      assert deg |> Maths.deg2rad() |> Maths.rad2deg() == deg
      assert rad |> Maths.rad2deg() |> Maths.deg2rad() == rad
    end
  end

  test "calculate_angle" do
    # 2D stuff
    values2d = [
      {[0, 0], [4, -4], Maths.deg2rad(45)},
      {[0, 0], [4, 4], Maths.deg2rad(135)},
      {[0, 0], [-4, 4], Maths.deg2rad(225)},
      {[0, 0], [-4, -4], Maths.deg2rad(315)},
      {[0, 0], [0, -1], 0},
      {[0, 0], [0, -4], 0},
      {[0, 0], [4, 0], Maths.deg2rad(90)},
      {[0, 0], [0, 4], Maths.deg2rad(180)},
      {[0, 0], [-4, 0], Maths.deg2rad(270)},
      {[10, 0], [103, 0], Maths.deg2rad(90)},
      # Approx 91 degrees
      {[10, -1], [103, 0], 1.58154}
    ]

    for {p1, p2, expected} <- values2d do
      result = Maths.calculate_angle(p1, p2)

      assert round(result, 2) == round(expected, 2),
        message:
          "Error with #{inspect(p1)} -> #{inspect(p2)}, expected #{inspect(deg(expected))} but got #{inspect(deg(result))}"
    end

    # 3D stuff
    values3d = [
      {[0, 0, 0], [4, -4, 0], [Maths.deg2rad(45), 0]},
      {[0, 0, 0], [4, 4, 0], [Maths.deg2rad(135), 0]},
      {[0, 0, 0], [-4, 4, 0], [Maths.deg2rad(225), 0]},
      {[0, 0, 0], [-4, -4, 0], [Maths.deg2rad(315), 0]},
      {[0, 0, 0], [4, -4, 4], [Maths.deg2rad(45), 0.6154797086703873]},
      {[0, 0, 0], [4, 4, 4], [Maths.deg2rad(135), 0.6154797086703873]},
      {[0, 0, 0], [-4, 4, 4], [Maths.deg2rad(225), 0.6154797086703873]},
      {[0, 0, 0], [-4, -4, 4], [Maths.deg2rad(315), 0.615479708670387]}
    ]

    for {p1, p2, _expected = [e1, e2]} <- values3d do
      _result = [r1, r2] = Maths.calculate_angle(p1, p2)

      msg =
        "Error with #{inspect(p1)} -> #{inspect(p2)}, expected #{inspect({deg(e1), deg(e2)})} but got #{inspect({deg(r1), deg(r2)})}"

      assert deg(r1) == deg(e1), message: msg
      assert deg(r2) == deg(e2), message: msg
    end
  end

  describe "rounding" do
    test "round_list/1" do
      assert Maths.round_list([1.1, 2.2, 3.3]) == [1, 2, 3]
      assert Maths.round_list([1, 2, 3]) == [1, 2, 3]

      assert Maths.round_list([1.1, -2.2, -3.3]) == [1, -2, -3]
      assert Maths.round_list([1, -2, -3]) == [1, -2, -3]
    end

    test "round/2" do
      assert Maths.round(1.123, 0) == 1
      assert Maths.round(1.123, 1) == 1.1
      assert Maths.round(1.123, 2) == 1.12
    end
  end

  # test "intersect" do
  #   values = [
  #     {},
  #   ]

  #   for {obj1, obj2, expected} <- values do
  #     result = Maths.intersect(p1, p2)
  #     assert round(result,2) == round(expected, 2), message: "Error with #{inspect p1} -> #{inspect p2}, expected #{inspect deg expected} but got #{inspect deg result}"
  #   end
  # end
end
