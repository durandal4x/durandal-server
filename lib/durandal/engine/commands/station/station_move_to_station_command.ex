defmodule Durandal.Engine.StationMoveToStationCommand do
  @moduledoc """

  """
  use Durandal.Engine.CommandMacro

  def category(), do: "station"
  def name(), do: "move_to_station"

  @spec parse(map()) :: {:ok, map()} | {:error, String.t()}
  def parse(params) do
    params
  end
end
