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
          "start_tick" => context.tick,
          "stop_tick" => context.tick
        },
        progress: 100
      })

    Engine.add_command_logs(context, command.id, [
      "Undocked #{ship.id} from #{ship.docked_with_id}"
    ])
  end
end
