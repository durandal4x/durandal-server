defmodule Durandal.Engine.Physics do
  @moduledoc """

  """

  import Durandal.Engine.Maths, only: [calculate_angle: 1, calculate_angle: 2, distance: 1, distance: 2, angle_distance: 2, angle_adjust: 2, limit_change: 3, angle: 1]
  alias Durandal.Engine.Maths

  @doc """
  Given a facing and an acceleration calculate the new velocity.

  This is functionally the same as calculating a location relative to a point given the facing and distance.
  """
  @spec apply_acceleration(Maths.facing(), number()) :: Maths.vector()
  def apply_acceleration(_, 0), do: [0, 0, 0]

  def apply_acceleration([fxy, fyz], acceleration) do
    # We calculate the 2D planes and multiply by vertical. If we are pointing
    # up then it doesn't matter if we're in theory pointing to the side too
    vx = :math.sin(fxy) * :math.cos(fyz)
    vy = :math.cos(fxy) * :math.cos(fyz)

    # Note, because of the way we use Y (down rather than up) in another 2D game it is possible the Y value needs to be inverted

    # Now we calculate the vz
    vz = :math.sin(fyz)

    # We flip the Y coordinate as for us incrementing Y takes us up
    [vx * acceleration, -vy * acceleration, vz * acceleration]
  end

  @doc """
  Uses suvat equation to calculate how long it will take to stop
  given your current velocity and your rate of acceleration

  (final velocity - initial velocity)/acceleration
  """
  @spec suvat_travel_time(Jam.distance(), Jam.distance()) :: number()
  def suvat_travel_time(velocity, acceleration) do
    acceleration = abs(acceleration)
    velocity / acceleration
  end

  @doc """
  Uses suvat equation to calculate how far you can go in a given time

  This can be used to calculate your stopping distance

  distance = VT - (ATT)/2
  """
  @spec suvat_travel_distance(Jam.distance(), number()) :: Jam.distance()
  def suvat_travel_distance(acceleration, time) do
    acceleration = abs(acceleration)
    # we calculate how far we'd go accelerating from 0 to current
    # as that's the same as going from current to 0!
    acceleration * time * time / 2
  end

  @doc """
  Given a velocity and an ideal heading, steer that velocity by a certain
  amount. Most obviously useful for something like a car but also useful
  if you wanted to have an intertial drive.
  """
  @spec steer(Maths.vector(), Maths.facing(), Integer) :: List
  def steer(velocity = [_, _, _], [target_xy, target_yz], amount) do
    velocity_scalar = distance(velocity)
    [xy, yz] = calculate_angle(velocity)
    adjust_xy = angle_adjust(xy, target_xy)
    adjust_yz = angle_adjust(yz, target_yz)

    new_turn = [limit_change(xy, adjust_xy, amount), limit_change(yz, adjust_yz, amount)]
    apply_acceleration(new_turn, velocity_scalar)
  end

  # Based on the position/velocity/acceleration of A and the position/velocity of B
  # should A speed up or slow down?
  def decelerate?(%{position: position, velocity: velocity, acceleration: acceleration}, target), do:
    decelerate?(position, velocity, acceleration, target)
  def decelerate?(position, velocity, acceleration, %{x: x, y: y, z: z}), do:
    decelerate?(position, velocity, acceleration, [x, y, z])
  def decelerate?(position, velocity, acceleration, target) do
    travel_time = suvat_travel_time(distance(velocity), acceleration)
    travel_distance = suvat_travel_distance(acceleration, travel_time)
    target_distance = distance(position, target)

    actual_heading = calculate_angle(velocity)
    target_heading = calculate_angle(position, target)
    [xy_dist, yz_dist] = angle_distance(actual_heading, target_heading)
    if xy_dist < (:math.pi/2) and yz_dist < (:math.pi/2) do
      (target_distance <= travel_distance)
    else
      false
    end
  end

  @doc """
  Given a position to move, a position to move about and the radians to move
  return an adjusted position.
  """
  @spec rotate_about_point(Maths.vector(), Maths.vector(), Maths.radians()) :: Maths.vector()
  def rotate_about_point(object_position, central_point, arc_size) do
    distance_to_point = distance(object_position, central_point)
    [angle_xy, _angle_yz] = calculate_angle(central_point, object_position)
    new_angle = [
      angle(angle_xy + arc_size),

      # Currently we're doing everything on a 2D plane so no rotation here
      0# angle(angle_yz + arc_size)
    ]

    # We now have the new angle to sit at and a distance, put them together
    # to find the location
    apply_acceleration(new_angle, distance_to_point)
  end
end
