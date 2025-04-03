defmodule Durandal.Engine.ShipOrbitSystemObjectCommand do
  @moduledoc """

  """
  use Durandal.Engine.CommandMacro

  def category(), do: "ship"
  def name(), do: "orbit_system_object"

  @spec parse(map()) :: {:ok, map()} | {:error, String.t()}
  def parse(params) do
    params
  end

  def execute(context, _command) do
    context
  end
end
