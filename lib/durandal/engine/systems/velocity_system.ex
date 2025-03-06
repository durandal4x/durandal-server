defmodule Durandal.Engine.VelocitySystem do
  @moduledoc """
  Moves objects based on their velocity
  """

  use Durandal.Engine.SystemMacro
  alias Durandal.Engine.Maths
  alias Durandal.Space

  def name(), do: "Velocity"
  def stage(), do: :physics

  @spec execute(Durandal.universe_id()) :: :ok | {:error, [String.t()]}
  def execute(universe_id) do
    # For all objects needing to move, move them
    update_ships(universe_id)
    update_stations(universe_id)
    update_system_objects(universe_id)
  end

  defp update_ships(universe_id) do
    Space.list_ships(where: [universe_id: universe_id, orbiting_id: :is_nil, docked_with_id: :is_nil])
    |> Enum.each(fn ship ->
      new_position = Maths.sum_vectors(ship.position, ship.velocity)

      if new_position != ship.position do
        Space.update_ship(ship, %{position: new_position})
      end
    end)
  end

  defp update_system_objects(universe_id) do
    Space.list_system_objects(where: [universe_id: universe_id, orbiting_id: :is_nil])
    |> Enum.each(fn system_object ->
      new_position = Maths.sum_vectors(system_object.position, system_object.velocity)

      if new_position != system_object.position do
        Space.update_system_object(system_object, %{position: new_position})
      end
    end)
  end

  defp update_stations(universe_id) do
    Space.list_stations(where: [universe_id: universe_id, orbiting_id: :is_nil])
    |> Enum.each(fn station ->
      new_position = Maths.sum_vectors(station.position, station.velocity)

      if new_position != station.position do
        Space.update_station(station, %{position: new_position})
      end
    end)
  end
end
