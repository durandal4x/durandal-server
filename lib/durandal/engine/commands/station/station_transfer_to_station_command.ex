defmodule Durandal.Engine.StationTransferToStationCommand do
  @moduledoc """

  """
  use Durandal.Engine.CommandMacro
  alias Durandal.{Space, Player}

  def category(), do: "station"
  def name(), do: "transfer_to_station"

  @spec parse(map()) :: {:ok, map()} | {:error, String.t()}
  def parse(params) do
    params
  end

  def execute(context, command) do
    station = Space.get_extended_station(command.subject_id)
    do_execute(context, command, station)
  end

  # Not currently in a transfer
  defp do_execute(context, command, %{current_transfer: nil} = station) do
    new_transfer(context, command, station)
  end

  # In a transfer, hopefully this one!
  defp do_execute(context, _command, %{current_transfer: %{status: "in progress"}} = _station) do
    context
  end

  defp new_transfer(context, command, station) do
    target_station = Space.get_station!(command.contents["station_id"])
    distance = Space.calculate_distance(station, target_station)

    {:ok, transfer} =
      Space.create_station_transfer(%{
        universe_id: station.universe_id,
        station_id: station.id,
        origin: station.position,
        to_station_id: target_station.id,
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

    {:ok, _station} =
      Space.update_station(station, %{
        orbiting_id: nil,
        current_transfer_id: transfer.id
      })

    context
  end

  def maybe_complete(context, command) do
    station = Space.get_extended_station(command.subject_id)
    do_maybe_complete(context, command, station)
  end

  # Not currently in a transfer
  defp do_maybe_complete(context, command, %{current_transfer_id: nil} = station) do
    transfer = Space.get_station_transfer(command.outcome["transfer_id"])

    case transfer do
      %{status: "complete"} ->
        new_outcome =
          Map.merge(command.outcome || %{}, %{
            stop_tick: context.tick
          })

        {:ok, _command} =
          Player.update_command(command, %{progress: 100, outcome: new_outcome})

        target_station = Space.get_station!(transfer.to_station_id)

        {:ok, _station} =
          Space.update_station(station, %{
            current_transfer_id: nil,
            velocity: target_station.velocity,
            orbiting_id: target_station.orbiting_id,
            orbit_clockwise: target_station.orbit_clockwise,
            orbit_period: target_station.orbit_period
          })

        context

      _ ->
        context
    end
  end

  defp do_maybe_complete(context, command, _station) do
    if command.outcome["transfer_id"] do
      # In a transfer, lets update our progress
      transfer = Space.get_station_transfer(command.outcome["transfer_id"])

      # It's in progress, we want to update the command to show the new progress
      {:ok, _command} =
        Player.update_command(command, %{
          progress: :math.floor(transfer.progress_percentage) |> round
        })
    end

    context
  end
end
