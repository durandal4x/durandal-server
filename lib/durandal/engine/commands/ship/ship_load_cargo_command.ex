defmodule Durandal.Engine.ShipLoadCargoCommand do
  @moduledoc """

  """
  use Durandal.Engine.CommandMacro
  # alias Durandal.{Space, Player, Resources}

  def category(), do: "ship"
  def name(), do: "load_cargo"

  @spec parse(map()) :: {:ok, map()} | {:error, String.t()}
  def parse(params) do
    resources =
      params["resources"]
      |> Enum.filter(fn [_, v] -> v > 0 end)

    total =
      params["resources"]
      |> Enum.map(fn [_, v] -> v end)
      |> Enum.sum()

    Map.merge(params, %{"resources" => resources, "total" => total})
  end

  def execute(context, command) do
    # ship = Space.get_extended_ship(command.subject_id)
    # do_execute(context, command, ship)
    context
  end
end
