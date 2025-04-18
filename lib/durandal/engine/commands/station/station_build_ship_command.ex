defmodule Durandal.Engine.StationBuildShipCommand do
  @moduledoc """

  """
  use Durandal.Engine.CommandMacro
  alias Durandal.{Space, Player, Types}

  def category(), do: "station"
  def name(), do: "build_ship"

  @spec parse(map()) :: {:ok, map()} | {:error, String.t()}
  def parse(params) do
    params
  end

  def execute(context, command) do
    station = Space.get_station!(command.subject_id)
    do_execute(context, command, station)
  end

  defp do_execute(context, command, station) do
    {command, ship} =
      if command.outcome["ship_id"] == nil do
        ship_type = Types.get_ship_type!(command.contents["ship_type_id"])

        ship = new_ship(command, ship_type, station)

        {:ok, new_command} =
          Player.update_command(command, %{
            outcome: %{
              "ship_id" => ship.id,
              "ship_type" => Jason.encode!(ship_type) |> Jason.decode!(),
              "start_tick" => context.tick
            }
          })

        {new_command, ship}
      else
        ship = Space.get_ship(command.outcome["ship_id"])
        {command, ship}
      end

    # Perform the actual command
    updated_ship = build_ship(command, ship)

    progress =
      (updated_ship.build_progress / command.outcome["ship_type"]["build_time"] * 100)
      |> :math.floor()
      |> round

    Player.update_command(command, %{progress: progress})
    context
  end

  defp new_ship(command, ship_type, station) do
    {:ok, ship} =
      Space.create_ship(%{
        name: Ecto.UUID.generate(),
        docked_with_id: station.id,
        team_id: station.team_id,
        type_id: command.contents["ship_type_id"],
        system_id: station.system_id,
        universe_id: station.universe_id,
        build_progress: 0,
        health: ship_type.max_health,
        position: station.position,
        velocity: [0, 0, 0]
      })

    ship
  end

  defp build_ship(command, ship) do
    new_progress =
      (ship.build_progress + Space.StationModuleLib.rate_of_progress())
      |> min(command.outcome["ship_type"]["build_time"])

    {:ok, updated_ship} =
      Space.update_ship(ship, %{
        build_progress: new_progress
      })

    updated_ship
  end

  def maybe_complete(context, _command) do
    context
  end
end
