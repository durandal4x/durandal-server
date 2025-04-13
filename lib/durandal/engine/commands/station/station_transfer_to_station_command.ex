defmodule Durandal.Engine.StationTransferToStationCommand do
  @moduledoc """

  """
  use Durandal.Engine.CommandMacro

  def category(), do: "station"
  def name(), do: "transfer_to_station"

  @spec parse(map()) :: {:ok, map()} | {:error, String.t()}
  def parse(params) do
    params
  end

  def execute(context, _command) do
    context
  end

  def maybe_complete(context, _command) do
    context
  end
end
