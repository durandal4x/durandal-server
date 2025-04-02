defmodule Durandal.Engine.ActionApplySystem do
  @moduledoc """
  Takes the actions for each entity and turns them into effects which will be used by other systems
  """

  use Durandal.Engine.SystemMacro
  alias Durandal.Space
  alias Durandal.Engine.{Maths, Physics}

  def name(), do: "ActionApply"
  def stage(), do: :apply_actions

  @spec execute(map()) :: map()
  def execute(context) do
    # Evaluate and execute (as much as possible) all actions listed
    apply_velocity_actions(context)

    context
  end

  defp apply_velocity_actions(context) do
    Engine.get_actions_by_tag(context, :velocity)
    |> Enum.each(&apply_velocity/1)

    context
  end

  defp apply_velocity(%{ship_id: id, direction: :stop} = action) do
    ship = Space.get_ship!(id, preload: [:type])
    extra_velocity = Physics.calculate_deceleration(ship.velocity, ship.type.acceleration)
    new_velocity = Maths.add_vector(ship.velocity, extra_velocity) |> Maths.round_list()
    # IO.inspect new_velocity, label: "S"

    {:ok, _} = Space.update_ship(ship, %{velocity: new_velocity})
  end

  defp apply_velocity(%{ship_id: id} = action) do
    ship = Space.get_ship!(id, preload: [:type])
    extra_velocity = Physics.apply_acceleration(action.direction, ship.type.acceleration)
    new_velocity = Maths.add_vector(ship.velocity, extra_velocity) |> Maths.round_list()
    # IO.inspect new_velocity, label: "A"
    {:ok, _} = Space.update_ship(ship, %{velocity: new_velocity})
  end

  defp apply_velocity(%{station_id: id} = action) do
    station = Space.get_station!(id, preload: [:type])
    extra_velocity = Physics.apply_acceleration(action.direction, station.type.acceleration)
    new_velocity = Maths.add_vector(station.velocity, extra_velocity) |> Maths.round_list()
    {:ok, _} = Space.update_station(station, %{velocity: new_velocity})
  end
end
