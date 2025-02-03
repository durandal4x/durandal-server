defmodule Durandal.Engine.CommandReadSystem do
  @moduledoc """
  A system which reads the player commands and puts them in a state ready to be
  used by future systems.
  """

  use Durandal.Engine.SystemMacro

  def name(), do: "CommandRead"
  def stage(), do: :player_commands

  @spec execute(Durandal.universe_id()) :: :ok | {:error, [String.t()]}
  def execute(_universe_id) do
    # Read orders
    # Drop orders which are no longer possible
  end
end
