defmodule Durandal.Space.DeleteShipTask do
  alias Durandal.Space

  @spec perform(Durandal.ship_id()) :: :ok | {:error, String.t()}
  def perform(ship_id) do
    ship = Space.get_ship!(ship_id)
    Space.delete_ship(ship)
  end
end
