defmodule Durandal.Engine.VelocitySystem do
  @moduledoc """
  Moves objects based on their velocity
  """

  use Durandal.Engine.SystemMacro
  alias Durandal.Engine.Maths

  def name(), do: "Velocity"
  def stage(), do: :physics

  @spec execute(Durandal.universe_id()) :: :ok | {:error, [String.t()]}
  def execute(universe_id) do
    # For all objects needing to move, move them
  end

  defp update_ships(universe_id) do
    ship_list = list_ships(where: [universe_id: universe_id])
    |> Enum.each(fn ship ->
      new_position = Maths.sum_vectors(ship.position, ship.velocity)

      if new_position != ship.position do
        update_ship(ship, %{position: new_position})
      end
    end)
  end
end
