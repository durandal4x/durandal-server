defmodule Durandal.Engine.Maths do
  @moduledoc """
  A set of functions for pure math calculations. All angle calculations are done
  in radians. If you want to use angles for presentation purposes it is advisable
  to convert from degree to radian as part of input sanitisation and convert to
  degree only when presenting a final value to the user.
  """
  @type degree() :: number()
  @type radian() :: number()
  @type vector() :: [number()]
  @type facing() :: [radian()]

  @pi :math.pi()
  @pi2 :math.pi() * 2

  @spec deg2rad([degree()]) :: [radian()]
  @spec deg2rad(degree()) :: radian()
  def deg2rad(vals) when is_list(vals), do: Enum.map(vals, &deg2rad/1)
  def deg2rad(360), do: @pi * 2
  def deg2rad(180), do: @pi
  def deg2rad(0), do: 0
  def deg2rad(d), do: d * (@pi / 180)

  @spec rad2deg([radian()]) :: [degree()]
  @spec rad2deg(radian()) :: degree()
  def rad2deg(vals) when is_list(vals), do: Enum.map(vals, &rad2deg/1)
  def rad2deg(0), do: 0
  def rad2deg(r), do: r * (180 / @pi)

  @doc """
  Given two vectors, sum them together
  """
  # def sum_vectors(a, b), do: Enum.zip(a, b) |> Enum.map(&(&1 + &2))
  @spec sum_vectors(vector(), vector()) :: vector()
  def sum_vectors(a, b) do
    Enum.zip(a, b)
    |> Enum.map(fn {aa, bb} -> aa + bb end)
  end

  @doc """
  limit/2 uses limit/3 but with the limiting value as a positive and a negative:

  limit(x, 2) => limit(x, -2, 2)
  """
  @spec limit(number(), number()) :: number()
  def limit(v, b), do: limit(v, -b, b)

  @doc """
  Method for limiting a number between two points
  call with 3rd parameter to limit plus or minus
  """
  @spec limit(number(), number(), number()) :: number()
  def limit(v, lb, ub) do
    cond do
      v < lb -> lb
      v > ub -> ub
      true -> v
    end
  end

  @doc """
  Limits the amount of change from the origin value, if the number is going to
  be changed by more than the limiting amount it will be bounded to that
  limiting amount

  ```
    > limit_change(10, 20, 5)
    15

    > limit_change(10, 20, 50)
    30
  ```
  """
  @spec limit_change(number(), number(), number()) :: number()
  def limit_change(origin, change, limit_amount) do
    lower_limit = origin - abs(limit_amount)
    upper_limit = origin + abs(limit_amount)

    limit(origin + change, lower_limit, upper_limit)
  end

  @doc """
  Given an angle, return the same angle but within 0 and 360 degrees
  """
  @spec angle(radian()) :: radian()
  def angle(a) do
    cond do
      a < 0 -> angle(a + @pi2)
      a > @pi2 -> angle(a - @pi2)
      true -> a
    end
  end

  @doc """
  Rotates an angle half a rotation but ensures the result sits within
  standard angular bounds
  """
  @spec invert_angle(radian()) :: radian()
  @spec invert_angle(facing()) :: facing()
  def invert_angle([xy, yz]), do: [invert_angle(xy), invert_angle(yz)]

  def invert_angle(a) do
    (a + @pi)
    |> angle
  end

  @doc """
  Gets the distance between a pair of coordinates. If only one set is given then an origin of
  [0,0,0] is used.
  """
  @spec distance(vector()) :: number()
  @spec distance(vector(), vector()) :: number()
  def distance([x1, y1]), do: distance([0, 0], [x1, y1])
  def distance([x1, y1, z1]), do: distance([0, 0, 0], [x1, y1, z1])

  def distance([x1, y1], [x2, y2]) do
    a = x1 - x2
    b = y1 - y2
    :math.sqrt(a * a + b * b)
  end

  def distance([x1, y1, z1], [x2, y2, z2]) do
    a = distance([x1, y1], [x2, y2])
    b = z2 - z1
    :math.sqrt(a * a + b * b)
  end

  @doc """
  Given angles a1 and a2 returns a left/right atom
  saying which way is the shortest way to turn

  :left = counter-clockwise or decrement
  :right = clockwise or increment
  """
  @spec shortest_angle(radian(), radian()) :: :equal | :left | :right
  def shortest_angle(a1, a2) do
    cond do
      # Both the same?
      a1 == a2 -> :equal
      # Standard closer/further
      a1 > a2 and a1 - a2 < @pi -> :left
      a2 > a1 and a2 - a1 < @pi -> :right
      # These cover when you need to cross 0 degrees
      a1 > a2 and a1 - a2 > @pi -> :right
      a2 > a1 and a2 - a1 > @pi -> :left
      # If the angles are opposites then we default to left
      true -> :left
    end
  end

  @doc """
  Given two angles, returns the actual adjustment needed to go from angle1 to angle 2
  """
  @spec angle_adjust(radian(), radian()) :: radian()
  def angle_adjust(a1, a2) do
    case shortest_angle(a1, a2) do
      :equal -> 0
      :left -> -angle_distance(a1, a2)
      :right -> angle_distance(a1, a2)
    end
  end

  @doc """
  Calculates the shortest angular distance between two angles, takes into
  account if the angles are either side of the 0 line.

  If given a list of angles you will get back a list of distances
  """
  @spec angle_distance(radian(), radian()) :: radian()
  @spec angle_distance(facing(), facing()) :: facing()
  def angle_distance([xy1, yz1], [xy2, yz2]),
    do: [angle_distance(xy1, xy2), angle_distance(yz1, yz2)]

  def angle_distance(a1, a2) do
    direction = shortest_angle(a1, a2)

    cond do
      # Same direction already?
      direction == :equal -> 0
      # Standard closer/further
      direction == :left and a1 > a2 -> a1 - a2
      direction == :right and a2 > a1 -> a2 - a1
      # These cover when you need to cross 0 degrees
      direction == :left and a1 < a2 -> @pi2 - (a2 - a1)
      direction == :right and a2 < a1 -> @pi2 - (a1 - a2)
    end
  end

  @doc """
  Given two angles, returns the actual adjustment needed to go from angle1 to angle 2
  """
  @spec adjust_required(radian(), radian()) :: radian()
  def adjust_required(a1, a2) do
    case shortest_angle(a1, a2) do
      :equal -> 0
      :left -> -angle_distance(a1, a2)
      :right -> angle_distance(a1, a2)
    end
  end

  @doc """
  Calculates the angle between two points in a 2D or 3D space, if 2D then one angle is returned, if 3D then a pair are returned for XY and YZ
  """
  @spec calculate_angle(vector(), vector()) :: radian() | facing()
  def calculate_angle([x1, y1]), do: calculate_angle([0, 0], [x1, y1])
  def calculate_angle([x1, y1, z1]), do: calculate_angle([0, 0, 0], [x1, y1, z1])

  def calculate_angle([x1, y1], [x2, y2]) do
    dx = x2 - x1
    dy = y2 - y1

    # Get 2D angle first
    sides =
      cond do
        # No angle, you are there already?
        dx == 0 and dy == 0 -> 0
        # Go up
        dx == 0 and dy < 0 -> 0
        # Go down
        dx == 0 and dy > 0 -> deg2rad(180)
        # Go left
        dx < 0 and dy == 0 -> deg2rad(270)
        # Go right
        dx > 0 and dy == 0 -> deg2rad(90)
        # Right, up
        dx > 0 and dy < 0 -> [abs(dx), abs(dy), 0]
        # Right, down
        dx > 0 and dy > 0 -> [abs(dy), abs(dx), deg2rad(90)]
        # Left, down
        dx < 0 and dy > 0 -> [abs(dx), abs(dy), deg2rad(180)]
        # Left, up
        dx < 0 and dy < 0 -> [abs(dy), abs(dx), deg2rad(270)]
      end

    case sides do
      [opp, adj, add] -> :math.atan(opp / adj) + add
      x -> x
    end
  end

  def calculate_angle([x1, y1, z1], [x2, y2, z2]) do
    xy = calculate_angle([x1, y1], [x2, y2])

    adj = distance([x1, y1], [x2, y2])
    opp = abs(z2 - z1)
    yz = if adj == 0, do: 0, else: :math.atan(opp / adj)

    [xy, yz]
  end

  @doc """
  Given two lists, add each value together and return a list of the summed values.
  """
  @spec add_vector(vector(), vector()) :: vector()
  def add_vector([x1, y1, z1], [x2, y2, z2]), do: [x1 + x2, y1 + y2, z1 + z2]

  @doc """
  Given two lists, subtract each value together and return a list of the values.
  """
  @spec sub_vector(vector(), vector()) :: vector()
  def sub_vector([x1, y1, z1], [x2, y2, z2]), do: [x1 - x2, y1 - y2, z1 - z2]

  @doc """
  Rounds a number to p decimal places. `p=0` will result in no decimal places and is the same as calling `round/1`
  """
  @spec round(number | [number], integer) :: integer | [integer]
  def round(vlist, p) when is_list(vlist), do: Enum.map(vlist, fn v -> round(v, p) end)
  def round(0, _p), do: 0
  def round(v, 0), do: round(v)
  def round(v, p), do: Float.round(v, p)

  @doc """
  Applies `round/1` to each element in a list
  """
  @spec round_list([number]) :: [integer]
  def round_list(vlist), do: Enum.map(vlist, &round/1)
end
