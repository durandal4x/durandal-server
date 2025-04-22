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

  # In a transfer, hopefully this one!
  defp do_execute(context, %{outcome: %{"transfer" => _transfer}} = command, station) do
    context
    |> do_transfer(command, station)
  end

  # Current command does not have transfer data, we need to make a new one
  defp do_execute(context, command, station) do
    {context, command, station} = new_transfer(context, command, station)
    do_transfer(context, command, station)
  end

  defp new_transfer(context, command, station) do
    target_station = Space.get_station!(command.contents["station_id"])
    distance = Space.calculate_distance(station, target_station)

    transfer = %{
      "origin" => station.position,
      "distance" => distance,
      "progress" => 0
    }

    # Update the command so it has a reference of the transfer
    {:ok, command} =
      Player.update_command(command, %{
        outcome: %{
          "transfer" => transfer,
          "start_tick" => context.tick
        }
      })

    # Station must be made to no longer be docked or orbiting
    {:ok, station} =
      Space.update_station(station, %{
        orbiting_id: nil,
        docked_with_id: nil
      })

    # Need to get the extended station
    station = Space.get_extended_station(station.id)

    {context, command, station}
  end

  defp do_transfer(context, %{outcome: %{"transfer" => transfer}} = command, station) do
    remaining = transfer["distance"] - transfer["progress"]

    cond do
      remaining == 0 ->
        complete_transfer(context, command, station)

      remaining < Durandal.Space.StationLib.station_acceleration() ->
        partial_progress_transfer(context, command, station)

      true ->
        progress_transfer(context, command, station)
    end
  end

  # Transfer completed, stop the station velocity
  defp complete_transfer(context, %{outcome: %{"transfer" => _transfer}} = command, station) do
    target_station = Space.get_station!(command.contents["station_id"])

    new_outcome =
      Map.merge(command.outcome || %{}, %{
        stop_tick: context.tick
      })

    {:ok, _command} =
      Player.update_command(command, %{progress: 100, outcome: new_outcome})

    {:ok, _station} =
      Space.update_station(station, %{
        current_transfer_id: nil,
        velocity: target_station.velocity,
        orbiting_id: target_station.orbiting_id,
        orbit_clockwise: target_station.orbit_clockwise,
        orbit_period: target_station.orbit_period
      })

    context
    |> Engine.add_command_logs(command.id, ["Completed transfer of #{station.id}"])
  end

  # Transfer nearly completed, move just enough we can stop next time
  defp partial_progress_transfer(
         context,
         %{outcome: %{"transfer" => transfer}} = command,
         station
       ) do
    target_station = Space.get_station!(command.contents["station_id"])

    velocity = Engine.Maths.sub_vector(target_station.position, station.position)

    {:ok, _} = Space.update_station(station, %{velocity: velocity})

    new_outcome =
      command.outcome
      |> put_in(~w(transfer progress), transfer["distance"])

    # We set it to 99 because if set to 100 it means the command is completed
    {:ok, _} = Player.update_command(command, %{outcome: new_outcome, progress: 99})

    context
    |> Engine.add_command_logs(command.id, ["Nearly completed transfer of #{station.id}"])
  end

  # Standard progression of transfer
  defp progress_transfer(context, %{outcome: %{"transfer" => transfer}} = command, station) do
    # TODO: Update the station velocity based on the acceleration and use that instead
    new_progress = (transfer["progress"] || 0) + Durandal.Space.StationLib.station_acceleration()
    progress_percentage = new_progress / transfer["distance"]
    target_station = Space.get_station!(command.contents["station_id"])

    new_position =
      Space.calculate_midpoint(transfer["origin"], target_station.position, progress_percentage)

    velocity = Engine.Maths.sub_vector(new_position, station.position)

    {:ok, _} = Space.update_station(station, %{velocity: velocity})

    new_outcome =
      command.outcome
      |> put_in(~w(transfer progress), new_progress)

    progress_percentage_int = (progress_percentage * 100) |> :math.floor() |> round()

    {:ok, _} =
      Player.update_command(command, %{outcome: new_outcome, progress: progress_percentage_int})

    context
    |> Engine.add_command_logs(command.id, ["Progressed transfer of #{station.id}"])
  end
end
