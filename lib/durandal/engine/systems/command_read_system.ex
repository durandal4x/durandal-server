defmodule Durandal.Engine.CommandReadSystem do
  @moduledoc """
  A system which reads the player commands and puts them in a state ready to be
  used by future systems.
  """

  use Durandal.Engine.SystemMacro
  alias Durandal.Player
  alias Durandal.Player.CommandLib

  def name(), do: "CommandRead"
  def stage(), do: :player_commands

  @doc """
  For each command, execute it and pass on the context to the next stage
  """
  @spec execute(map()) :: :ok | {:error, [String.t()]}
  def execute(context) do
    context.universe_id
    |> Player.CommandQueries.pull_most_recent_commands()
    |> Enum.reduce(context, fn command, acc ->
      {:ok, module} = CommandLib.get_command_module(command.subject_type, command.command_type)
      module.execute(acc, command)
    end)
    |> apply_command_deletes
    |> apply_command_updates
  end

  defp apply_command_deletes(context) do
    context
  end

  defp apply_command_updates(context) do
    changes = context.command_changes
    |> Map.new(fn {command_id, changes} ->
      {command_id,
        changes
        |> Enum.reverse
        |> Enum.reduce(%{}, fn (c, acc) ->
          Map.merge(acc, c)
        end)
      }
    end)

    # If no changes don't do a query of course
    if not Enum.empty?(changes) do
      command_ids = Map.keys(changes)

      Player.list_commands(
        where: [
          id: command_ids,
          universe_id: context.universe_id
        ],
        limit: :infinity
      )
      |> Enum.each(fn command ->
        new_contents = Map.merge(command.contents, changes[command.id])
        {:ok, _} = Player.update_command(command, %{contents: new_contents})
      end)
    end

    context
  end
end
