defmodule Durandal.Engine.InstructionUpdateSystem do
  @moduledoc """
  Evaluate the current instructions and update them as necessary.
  """

  use Durandal.Engine.SystemMacro

  def name(), do: "InstructionUpdate"
  def stage(), do: :internal_instructions

  @spec execute(map()) :: map()
  def execute(context) do
    # Evaluate if the current instruction needs to change
    # Change/Drop instructions which are no longer relevant

    context
  end
end
