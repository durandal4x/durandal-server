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
    update_systems(universe_id)
    update_system_objects(universe_id)
  end

  defp update_ships(universe_id) do
    Space.list_ships(where: [universe_id: universe_id])
    |> Enum.each(fn ship ->
      new_position = Maths.sum_vectors(ship.position, ship.velocity)

      if new_position != ship.position do
        Space.update_ship(ship, %{position: new_position})
      end
    end)
  end

  defp update_system_objects(universe_id) do
    Space.list_system_objects(where: [universe_id: universe_id])
    |> Enum.each(fn system_object ->
      new_position = Maths.sum_vectors(system_object.position, system_object.velocity)

      if new_position != system_object.position do
        Space.update_system_object(system_object, %{position: new_position})
      end
    end)
  end

  defp update_systems(universe_id) do
    Space.list_systems(where: [universe_id: universe_id])
    |> Enum.each(fn system ->
      new_position = Maths.sum_vectors(system.position, system.velocity)

      if new_position != system.position do
        Space.update_system(system, %{position: new_position})
      end
    end)
  end
end
