defmodule Durandal.Engine.TickTask do
  alias Durandal.Engine
  # alias Durandal.Game.UniverseLib
  require Logger

  def perform_tick(universe_id) do
    Logger.info("Ticking #{universe_id}")

    :telemetry.span(
      [:durandal, :engine, :tick],
      %{universe_id: universe_id, start: 1},
      fn ->
        # Run through each stage
        Engine.evaluation_stages()
        |> Enum.each(fn stage ->
          run_stage(universe_id, stage)
        end)

        {:ok, %{universe_id: universe_id, metadata: "Info1", start: 1}}
      end
    )
  end

  @spec run_stage(Durandal.universe_id(), atom) :: :ok | {:error, [String.t()]}
  def run_stage(universe_id, stage) do
    :telemetry.span(
      [:durandal, :engine, :stage],
      %{universe_id: universe_id, stage: stage},
      fn ->
        Map.get(Engine.systems_by_stage(), stage, [])
        |> Enum.each(fn {_name, system_module} ->
          run_system(universe_id, system_module)
        end)

        {:ok, %{universe_id: universe_id, stage: stage, metadata: "Info2"}}
      end
    )
  end

  @spec run_system(Durandal.universe_id(), module) :: :ok | {:error, [String.t()]}
  def run_system(universe_id, module) do
    :telemetry.span(
      [:durandal, :engine, :system],
      %{universe_id: universe_id, module: module},
      fn ->
        module.execute(universe_id)

        {:ok, %{universe_id: universe_id, module: module, metadata: "Info3"}}
      end
    )
  end
end
