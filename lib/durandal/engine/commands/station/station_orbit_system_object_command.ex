defmodule Durandal.Engine.StationOrbitSystemObjectCommand do
  @moduledoc """

  """
  use Durandal.Engine.CommandMacro

  def category(), do: "station"
  def name(), do: "orbit_system_object"

  @spec parse(map()) :: {:ok, map()} | {:error, String.t()}
  def parse(params) do
    params
  end
end
