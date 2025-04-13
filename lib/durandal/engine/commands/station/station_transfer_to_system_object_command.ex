defmodule Durandal.Engine.StationTransferToSystemObjectCommand do
  @moduledoc """

  """
  use Durandal.Engine.CommandMacro

  def category(), do: "station"
  def name(), do: "transfer_to_system_object"

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
