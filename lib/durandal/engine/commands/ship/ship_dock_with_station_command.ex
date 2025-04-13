defmodule Durandal.Engine.ShipDockWithStationCommand do
  @moduledoc """

  """
  use Durandal.Engine.CommandMacro
  alias Durandal.{Space, Player}

  @docking_range 1_000

  def category(), do: "ship"
  def name(), do: "dock_at_station"

  @spec parse(map()) :: {:ok, map()} | {:error, String.t()}
  def parse(params) do
    params
  end

  def execute(context, command) do
    ship = Space.get_extended_ship(command.subject_id)
    do_execute(context, command, ship)
  end

  defp do_execute(context, command, %{docked_with_id: nil} = ship) do
    station = Space.get_station(command.contents["station_id"])

    case can_dock?(ship, station) do
      true ->
        {:ok, _} = Space.update_ship(ship, %{docked_with_id: command.contents["station_id"]})
        # Update the command so it has a reference of the transfer
        {:ok, _command} =
          Player.update_command(command, %{
            outcome: %{
              "start_tick" => context.tick
            }
          })

        Engine.add_command_logs(context, command.id, [
          "Docked #{ship.id} with #{command.contents["station_id"]}"
        ])

      {false, reason_code, _ops} ->
        Engine.add_command_logs(context, command.id, [
          "Unable to dock #{ship.id} with #{command.contents["station_id"]} because #{reason_code}"
        ])
    end
  end

  defp do_execute(context, command, ship) do
    Engine.add_command_logs(context, command.id, [
      "Unable to dock #{ship.id} with #{command.contents["station_id"]} as already docked at #{ship.docked_with_id}"
    ])
  end

  def maybe_complete(context, command) do
    ship = Space.get_extended_ship(command.subject_id)
    do_maybe_complete(context, command, ship)
  end

  defp do_maybe_complete(context, _command, %{docked_with_id: nil} = _ship) do
    context
  end

  defp do_maybe_complete(context, command, _ship) do
    new_outcome =
      Map.merge(command.outcome || %{}, %{
        stop_tick: context.tick
      })

    {:ok, _command} = Player.update_command(command, %{completed?: true, outcome: new_outcome})
    context
  end

  defp can_dock?(ship, station) do
    cond do
      ship.team_id != station.team_id ->
        {false, "docking_failure_different_teams", []}

      Engine.Maths.distance(ship.position, station.position) > @docking_range ->
        {false, "docking_failure_distance_too_great",
         [Engine.Maths.distance(ship.position, station.position)]}

      true ->
        true
    end
  end
end
