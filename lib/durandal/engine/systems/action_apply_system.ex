defmodule Durandal.Engine.ActionApplySystem do
  @moduledoc """
  Takes the actions for each entity and turns them into effects which will be used by other systems
  """

  use Durandal.Engine.SystemMacro

  def name(), do: "ActionApply"
  def stage(), do: :apply_actions

  @spec execute(Durandal.universe_id()) :: :ok | {:error, [String.t()]}
  def execute(_universe_id) do
    # Evaluate and execute (as much as possible) all actions listed
  end
end
