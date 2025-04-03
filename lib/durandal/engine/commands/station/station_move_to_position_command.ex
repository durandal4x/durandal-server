defmodule Durandal.Engine.StationMoveToPositionCommand do
  @moduledoc """

  """
  use Durandal.Engine.CommandMacro

  def category(), do: "station"
  def name(), do: "move_to_position"

  @spec parse(map()) :: {:ok, map()} | {:error, String.t()}
  def parse(params) do
    Map.merge(params, %{
      "position" => Enum.map(params["position"], &String.to_integer/1)
    })
  end

  def execute(context, _command) do
    context
  end
end
