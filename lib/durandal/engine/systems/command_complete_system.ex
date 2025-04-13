defmodule Durandal.Engine.CommandCompleteSystem do
  @moduledoc """
  A system which reads the player commands and puts them in a state ready to be
  used by future systems.
  """

  use Durandal.Engine.SystemMacro
  alias Durandal.Player
  alias Durandal.Player.CommandLib

  def name(), do: "CommandComplete"
  def stage(), do: :player_commands_post_process

  @doc """
  For each command, check if we need to mark it as complete
  """
  @spec execute(map()) :: :ok | {:error, [String.t()]}
  def execute(context) do
    context.universe_id
    |> Player.CommandQueries.pull_most_recent_commands()
    |> Enum.reduce(context, fn command, acc ->
      {:ok, module} = CommandLib.get_command_module(command.subject_type, command.command_type)
      module.maybe_complete(acc, command)
    end)
  end
end
