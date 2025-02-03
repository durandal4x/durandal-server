defmodule Durandal.Engine.Maths do
  @pi :math.pi
  @pi2 :math.pi*2

  @spec sum_vectors([number()], [number()]) :: [number()]
  def sum_vectors([x1, y1, z1], [x2, y2, z2]) do
    [x1 + x2, y1 + y2, z1 + z2]
  end

  def deg2rad(vals) when is_list(vals), do: Enum.map(vals, &deg2rad/1)
  def deg2rad(d), do: d * (@pi/180)

  # def rad2deg([a, b]), do: [rad2deg(a), rad2deg(b)]
  def rad2deg(vals) when is_list(vals), do: Enum.map(vals, &rad2deg/1)
  def rad2deg(r), do: r * (180/@pi)

  def get_coords(%{x: x, y: y, z: z}), do: [x, y, z]
  # def get_coords(%{vx: x, vy: y, vz: z}, :v), do: [x, y, z]
  # def add_vector([x1, y1, z1], [x2, y2, z2]), do: [x1 + x2, y1 + y2, z1 + z2]

  def round_list(l), do: Enum.map(l, &round/1)

  @doc """
  Given a value and two bounds will return the value or the bound over which
  the value crosses and an atom with the type of bound (:max, :min, :valid)

  > bound(3, 1, 5)
  > {3, false}

  > bound(15, 1, 5)
  > 5

  > bound(-2, 1, 5)
  > 1

  The boundaries do not need to be in order
  """
  @spec bound(number, number, number) :: {number, :max | :min | :valid}
  def bound(value, b1, b2) do
    minimum = min(b1, b2)
    maximum = max(b1, b2)

    cond do
      value > maximum -> {maximum, :max}
      value < minimum -> {minimum, :min}
      true -> {value, :valid}
    end
  end

  # Limits the amount of change from the origin value
  def bound_change(origin, change, bound_amount) do
    lower_bound = origin - abs(bound_amount)
    upper_bound = origin + abs(bound_amount)

    bound(origin + change, lower_bound, upper_bound)
  end

  # Given an angle, return the same angle but within 0 and 360 degrees
  def angle(a) do
    cond do
      a < 0 -> angle(a + @pi2)
      a > @pi2 -> angle(a - @pi2)
      true -> a
    end
  end

  @doc """
  Rotates an angle about half a rotation but ensures the result sits within
  standard angular bounds
  """
  @spec invert_angle(float) :: float
  @spec invert_angle(List) :: List
  def invert_angle([xy, yz]), do: [invert_angle(xy), invert_angle(yz)]
  def invert_angle(a) do
    (a + @pi)
    |> angle
  end

  @doc """
  Pythagoras on 2D or 3D. If only given one set of coodinates it assumes an origin of [0,0,0]
  """
  def distance([x1, y1]), do: distance([0, 0], [x1, y1])
  def distance([x1, y1, z1]), do: distance([0, 0, 0], [x1, y1, z1])
  def distance(%{x: x, y: y, z: z}, b), do: distance([x, y, z], b)
  def distance(a, %{x: x, y: y, z: z}), do: distance(a, [x, y, z])
  def distance([x1, y1], [x2, y2]) do
    a = x1 - x2
    b = y1 - y2
    :math.sqrt((a*a) + (b*b))
  end

  def distance([x1, y1, z1], [x2, y2, z2]) do
    a = distance([x1, y1], [x2, y2])
    b = z2 - z1
    :math.sqrt((a*a) + (b*b))
  end

  @doc """
  Given angles a1 and a2 returns a left/right atom
  saying which way is the shortest way to turn
  """
  @spec shortest_angle(float, float) :: :equal | :left | :right
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
  Calculates the shortest angular distance between two angles, takes into
  account if the angles are either side of the 0/360 line
  """
  @spec angle_distance(float, float) :: float
  @spec angle_distance(List, List) :: List
  def angle_distance([xy1, yz1], [xy2, yz2]), do: [angle_distance(xy1, xy2), angle_distance(yz1, yz2)]
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
  @spec angle_adjust(float, float) :: float
  def angle_adjust(a1, a2) do
    case shortest_angle(a1, a2) do
      :equal -> 0
      :left -> -angle_distance(a1, a2)
      :right -> angle_distance(a1, a2)
    end
  end

  @doc """
  Calculates the angle between two points in a 2D or 3D space, if 2D then one angle is returned, if 3D then a pair are returned for XY and YZ
  """
  @spec calculate_angle(List, List) :: float | List
  def calculate_angle([x1, y1]), do: calculate_angle([0, 0], [x1, y1])
  def calculate_angle([x1, y1, z1]), do: calculate_angle([0, 0, 0], [x1, y1, z1])
  def calculate_angle([x1, y1], [x2, y2]) do
    dx = x2 - x1
    dy = y2 - y1

    # Get 2D angle first
    sides = cond do
      dx == 0 and dy == 0 -> 0 # No angle, you are there already?
      dx == 0 and dy < 0 -> 0 # Go up
      dx == 0 and dy > 0 -> deg2rad(180) # Go down
      dx < 0 and dy == 0 -> deg2rad(270) # Go left
      dx > 0 and dy == 0 -> deg2rad(90) # Go right

      dx > 0 and dy < 0 -> [abs(dx), abs(dy), 0] # Right, up
      dx > 0 and dy > 0 -> [abs(dy), abs(dx), deg2rad(90)] # Right, down
      dx < 0 and dy > 0 -> [abs(dx), abs(dy), deg2rad(180)] # Left, down
      dx < 0 and dy < 0 -> [abs(dy), abs(dx), deg2rad(270)] # Left, up
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

  # def intercept_vector(
  #   %{x: x1, y: y1, z: z1},
  #   %{x: _, y: _, z: _}
  # ) do
  # def intercept_vector(a, b) do
  #   bposition = [b.x, b.y, b.z]
  #   bspeed = distance([b.vx, b.by, b.vz])
  #   bangle = calculate_angle([b.vx, b.by, b.vz])
  # end
end
