defmodule Durandal.Engine.ShipUndockFromStationCommand do
  @moduledoc """

  """
  use Durandal.Engine.CommandMacro
  alias Durandal.{Space, Player}

  def category(), do: "ship"
  def name(), do: "undock_from_station"

  @spec parse(map()) :: {:ok, map()} | {:error, String.t()}
  def parse(params) do
    params
  end

  def execute(context, command) do
    ship = Space.get_extended_ship(command.subject_id)
    do_execute(context, command, ship)
  end

  defp do_execute(context, command, %{docked_with_id: nil} = ship) do
    Engine.add_command_logs(context, command.id, [
      "Unable to undock #{ship.id} as not docked anywhere"
    ])
  end

  defp do_execute(context, command, ship) do
    station = Space.get_station!(ship.docked_with_id)

    {:ok, _} =
      Space.update_ship(ship, %{
        docked_with_id: nil,
        position: station.position,
        velocity: station.velocity,
        orbiting_id: station.orbiting_id,
        orbit_clockwise: station.orbit_clockwise,
        orbit_period: station.orbit_period
      })

    {:ok, _command} =
      Player.update_command(command, %{
        outcome: %{
          "start_tick" => context.tick
        }
      })

    Engine.add_command_logs(context, command.id, [
      "Undocked #{ship.id} from #{ship.docked_with_id}"
    ])
  end

  def maybe_complete(context, command) do
    ship = Space.get_extended_ship(command.subject_id)
    do_maybe_complete(context, command, ship)
  end

  defp do_maybe_complete(context, command, %{docked_with_id: nil} = _ship) do
    new_outcome =
      Map.merge(command.outcome || %{}, %{
        stop_tick: context.tick
      })

    {:ok, _command} = Player.update_command(command, %{completed?: true, outcome: new_outcome})
    context
  end

  defp do_maybe_complete(context, _command, _ship) do
    context
  end
end
