defmodule Durandal.Engine.OrbitSystem do
  @moduledoc """
  Updates object velocities based on their orbits
  """

  use Durandal.Engine.SystemMacro
  alias Durandal.Engine.{Maths, Physics}
  alias Durandal.Space

  def name(), do: "Orbit"
  def stage(), do: :physics

  @pi2 :math.pi() * 2

  @spec execute(Durandal.universe_id()) :: :ok | {:error, [String.t()]}
  def execute(universe_id) do
    # For all objects needing to move, move them
    update_ships(universe_id)
    update_stations(universe_id)
    update_system_objects(universe_id)
  end

  defp update_ships(universe_id) do
    Space.list_ships(where: [universe_id: universe_id, orbiting_id: :not_nil], preload: [:orbiting])
    |> Enum.each(fn ship ->
      arc_size = @pi2/ship.orbit_period * (if ship.orbit_clockwise, do: 1, else: -1)
      new_position = Physics.rotate_about_point(ship.position, ship.orbiting.position, arc_size)

      if new_position != ship.position do
        Space.update_ship(ship, %{position: new_position})
      end
    end)
  end

  defp update_system_objects(universe_id) do
    Space.list_system_objects(where: [universe_id: universe_id, orbiting_id: :not_nil], preload: [:orbiting])
    |> Enum.each(fn system_object ->
      arc_size = @pi2/system_object.orbit_period * (if system_object.orbit_clockwise, do: 1, else: -1)
      new_position = Physics.rotate_about_point(system_object.position, system_object.orbiting.position, arc_size)
      |> Maths.round_list()

      IO.puts ""
      IO.inspect new_position, label: "#{__MODULE__}:#{__ENV__.line}"
      IO.inspect system_object.position, label: "#{__MODULE__}:#{__ENV__.line}"
      IO.puts ""

      if new_position != system_object.position do
        Space.update_system_object(system_object, %{position: new_position})
      end
    end)
  end

  defp update_stations(universe_id) do
    Space.list_stations(where: [universe_id: universe_id, orbiting_id: :not_nil], preload: [:orbiting])
    |> Enum.each(fn station ->
      arc_size = @pi2/station.orbit_period * (if station.orbit_clockwise, do: 1, else: -1)
      new_position = Physics.rotate_about_point(station.position, station.orbiting.position, arc_size)

      if new_position != station.position do
        Space.update_station(station, %{position: new_position})
      end
    end)
  end
end
