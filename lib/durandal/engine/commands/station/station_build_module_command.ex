defmodule Durandal.Engine.StationBuildModuleCommand do
  @moduledoc """

  """
  use Durandal.Engine.CommandMacro
  alias Durandal.{Space, Player, Types}

  def category(), do: "station"
  def name(), do: "build_module"

  @spec parse(map()) :: {:ok, map()} | {:error, String.t()}
  def parse(params) do
    params
  end

  def execute(context, command) do
    # station = Space.get_extended_station(command.subject_id)
    do_execute(context, command)
  end

  defp do_execute(context, command) do
    {command, module} =
      if command.outcome["station_module_id"] == nil do
        module_type = Types.get_station_module_type!(command.contents["module_type_id"])

        station_module = new_module(command, module_type)

        {:ok, new_command} =
          Player.update_command(command, %{
            outcome: %{
              "station_module_id" => station_module.id,
              "module_type" => Jason.encode!(module_type) |> Jason.decode!(),
              "start_tick" => context.tick
            }
          })

        {new_command, station_module}
      else
        station_module = Space.get_station_module(command.outcome["station_module_id"])
        {command, station_module}
      end

    # Perform the actual command
    updated_module = build_module(command, module)

    progress =
      (updated_module.build_progress / command.outcome["module_type"]["build_time"] * 100)
      |> :math.floor()
      |> round

    Player.update_command(command, %{progress: progress})
    context
  end

  defp new_module(command, module_type) do
    {:ok, station_module} =
      Space.create_station_module(%{
        station_id: command.subject_id,
        type_id: command.contents["module_type_id"],
        universe_id: command.universe_id,
        build_progress: 0,
        health: module_type.max_health
      })

    station_module
  end

  defp build_module(command, module) do
    new_progress =
      (module.build_progress + Space.StationModuleLib.rate_of_progress())
      |> min(command.outcome["module_type"]["build_time"])

    {:ok, updated_module} =
      Space.update_station_module(module, %{
        build_progress: new_progress
      })

    updated_module
  end

  def maybe_complete(context, _command) do
    context
  end
end
