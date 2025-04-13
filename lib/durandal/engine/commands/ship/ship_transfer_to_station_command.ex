defmodule Durandal.Engine.ShipTransferToStationCommand do
  @moduledoc """

  """
  use Durandal.Engine.CommandMacro
  alias Durandal.{Space, Player}

  def category(), do: "ship"
  def name(), do: "transfer_to_station"

  @spec parse(map()) :: {:ok, map()} | {:error, String.t()}
  def parse(params) do
    params
  end

  def execute(context, command) do
    ship = Space.get_extended_ship(command.subject_id)
    do_execute(context, command, ship)
  end

  # Not currently in a transfer
  defp do_execute(context, command, %{current_transfer: nil} = ship) do
    new_transfer(context, command, ship)
  end

  # In a transfer, hopefully this one!
  defp do_execute(context, _command, %{current_transfer: %{status: "in progress"}} = _ship) do
    context
  end

  defp new_transfer(context, command, ship) do
    station = Space.get_station!(command.contents["station_id"])
    distance = Space.calculate_distance(ship, station)

    {:ok, transfer} =
      Space.create_ship_transfer(%{
        universe_id: ship.universe_id,
        ship_id: ship.id,
        origin: ship.position,
        to_station_id: station.id,
        progress: 0,
        status: "in progress",
        started_tick: context.tick,
        distance: distance
      })

    # Update the command so it has a reference of the transfer
    {:ok, _command} =
      Player.update_command(command, %{
        outcome: %{
          "transfer_id" => transfer.id,
          "start_tick" => context.tick
        }
      })

    {:ok, _ship} = Space.update_ship(ship, %{current_transfer_id: transfer.id})

    context
  end

  def maybe_complete(context, command) do
    ship = Space.get_extended_ship(command.subject_id)
    do_maybe_complete(context, command, ship)
  end

  # Not currently in a transfer
  defp do_maybe_complete(context, command, %{current_transfer_id: nil} = ship) do
    transfer = Space.get_ship_transfer(command.contents["transfer_id"])

    case transfer do
      %{status: "complete"} ->
        new_outcome =
          Map.merge(command.outcome || %{}, %{
            stop_tick: context.tick
          })

        {:ok, _command} =
          Player.update_command(command, %{completed?: true, outcome: new_outcome})

        station = Space.get_station!(transfer.to_station_id)

        {:ok, _ship} =
          Space.update_ship(ship, %{
            current_transfer_id: nil,
            velocity: station.velocity,
            orbiting_id: station.orbiting_id,
            orbit_clockwise: station.orbit_clockwise,
            orbit_period: station.orbit_period
          })

        context

      _ ->
        context
    end
  end

  defp do_maybe_complete(context, _command, _ship) do
    context
  end
end
