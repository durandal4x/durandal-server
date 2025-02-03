defmodule Durandal.Engine.Physics do
  @moduledoc """

  """

  import Durandal.Engine.Maths, only: [calculate_angle: 1, calculate_angle: 2, distance: 1, distance: 2, angle_distance: 2, angle_adjust: 2, limit_change: 3]

  @doc """

  """
  @spec apply_acceleration(List, Integer) :: List
  def apply_acceleration(_, 0), do: [0, 0, 0]
  def apply_acceleration(%{fxy: fxy, fyz: fyz}, acceleration), do: apply_acceleration([fxy, fyz], acceleration)
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

  def suvat_stop_time(velocity, acceleration) do
    acceleration = abs(acceleration)
    # (final velocity - initial velocity)/acceleration
    velocity/acceleration
  end

  def suvat_stop_distance(acceleration, time) do
    acceleration = abs(acceleration)
    # distance = VT - (ATT)/2
    # we want to calculate how far we'd go accelerating from 0 to current
    # velocity, it gives us the same as the stop distance
    ((acceleration * time * time) / 2)
  end

  @doc """
  Given a velocity and an ideal heading, steer that velocity by a certain
  amount. Most obviously useful for something like a car but also useful
  if you wanted to have an intertial drive.
  """
  @spec steer(List, List, Integer) :: List
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
    stop_time = suvat_stop_time(distance(velocity), acceleration)
    stop_distance = suvat_stop_distance(acceleration, stop_time)
    target_distance = distance(position, target)

    actual_heading = calculate_angle(velocity)
    target_heading = calculate_angle(position, target)
    [xy_dist, yz_dist] = angle_distance(actual_heading, target_heading)
    if xy_dist < (:math.pi/2) and yz_dist < (:math.pi/2) do
      (target_distance <= stop_distance)
    else
      false
    end
  end
end
