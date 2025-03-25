defmodule Durandal.Engine.ShipMoveToPositionCommand do
  @moduledoc """

  """
  use Durandal.Engine.CommandMacro
  alias Durandal.Space
  alias Durandal.Engine.Maths

  def category(), do: "ship"
  def name(), do: "move_to_position"

  @spec parse(map()) :: {:ok, map()} | {:error, String.t()}
  def parse(params) do
    Map.merge(params, %{
      "position" => Enum.map(params["position"], &String.to_integer/1)
    })
  end

  @spec execute(map(), Durandal.Player.Command.t()) :: map()
  def execute(context, command) do
    case Space.get_ship(command.subject_id) do
      nil ->
        context

      ship ->
        target_direction = Maths.calculate_angle(ship.position, command.contents["position"])

        Engine.add_action(context, command.subject_id, [:velocity], %{
          ship_id: command.subject_id,
          direction: target_direction
        })
    end
  end

  defp create_stages(%{contents: %{"stages" => _}} = command), do: command
  defp create_stages(command) do
    # Thrust forwards X ticks
    # Flip
    # Burn for Y ticks
    # Come to a stop?
  end

  defp calculate_situational_hash(ship, target_position) do
    v0 = existing_velocity
    a_t = acceleration
    r_a = ship_pos
    r_b = target_pos

    calculate_thrust_durations(v0, r_a, r_b, a_t)
  end

  def calculate_thrust_durations(v0, r_a, r_b, a_t) do
    # Calculate distance from A to B
    d = Vector.distance(r_a, r_b)

    # Initial velocity vector and peak velocity calculation
    v_peak = calc_v_peak(v0, d, a_t)

    # Calculate time for acceleration (t1)
    t1 = calc_time_for_acceleration(v0, v_peak, a_t)

    # Calculate time for deceleration (t2)
    t2 = calc_time_for_deceleration(v_peak, a_t)

    # Verify total distance
    if verify_total_distance(v0, t1, a_t, v_peak, t2) == d do
      {:ok, t1: t1, t2: t2}
    else
      {:error, :distance_mismatch}
    end
  end

  defp calc_v_peak(v0, d, a_t) do
    # Assuming no external forces and stopping at B (v_f = 0)
    # Using energy conservation or kinematic equations
    v_peak = :math.sqrt(v0 * v0 + 2 * a_t * d)
    v_peak
  end

  defp calc_time_for_acceleration(v0, v_peak, a_t) do
    t1 = (v_peak - v0) / a_t
    t1
  end

  defp calc_time_for_deceleration(v_peak, a_t) do
    t2 = v_peak / a_t
    t2
  end

  defp verify_total_distance(v0, t1, a_t, v_peak, t2) do
    d_accelerated = v0 * t1 + 0.5 * a_t * :math.pow(t1, 2)
    d_decelerated = v_peak * t2 - 0.5 * a_t * :math.pow(t2, 2)

    d_accelerated + d_decelerated
  end
end
