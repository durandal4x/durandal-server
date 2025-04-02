defmodule Durandal.Engine.TickTask do
  alias Durandal.Engine
  # alias Durandal.Game.UniverseLib
  require Logger

  defp starting_context(universe_id) do
    %{
      universe_id: universe_id,
      actions: %{},
      actions_by_subject_id: %{},
      actions_by_tag: %{},
      command_changes: %{},
      command_deletes: []
    }
  end

  def perform_tick(universe_id) do
    Logger.info("Ticking #{universe_id}")

    :telemetry.span(
      [:durandal, :engine, :tick],
      %{universe_id: universe_id},
      fn ->
        # Run through each stage
        result =
          Engine.evaluation_stages()
          |> Enum.reduce(starting_context(universe_id), fn stage, context ->
            run_stage(universe_id, stage, context)
          end)

        {result, %{universe_id: universe_id, metadata: "Info1"}}
      end
    )
  end

  @spec run_stage(Durandal.universe_id(), atom, map()) :: map()
  def run_stage(universe_id, stage, existing_context) do
    :telemetry.span(
      [:durandal, :engine, :stage],
      %{universe_id: universe_id, stage: stage},
      fn ->
        result =
          Map.get(Engine.systems_by_stage(), stage, [])
          |> Enum.reduce(existing_context, fn {_name, system_module}, context ->
            run_system(universe_id, system_module, context)
          end)

        {result, %{universe_id: universe_id, stage: stage}}
      end
    )
  end

  @spec run_system(Durandal.universe_id(), module, map()) :: map()
  def run_system(universe_id, module, context) do
    :telemetry.span(
      [:durandal, :engine, :system],
      %{universe_id: universe_id, module: module},
      fn ->
        result = module.execute(context)

        {result, %{universe_id: universe_id, module: module}}
      end
    )
  end
end
