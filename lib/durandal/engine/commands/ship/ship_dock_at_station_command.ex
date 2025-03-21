defmodule Durandal.Engine.DockAtStationCommand do
  @moduledoc """

  """
  use Durandal.Engine.CommandMacro

  def category(), do: "ship"
  def name(), do: "dock_at_station"

  @spec parse(map()) :: {:ok, map()} | {:error, String.t()}
  def parse(params) do
    params
  end
end
