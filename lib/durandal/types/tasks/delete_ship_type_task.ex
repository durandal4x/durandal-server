defmodule Durandal.Types.DeleteShipTypeTask do
  alias Durandal.Types

  @spec perform(Durandal.ship_type_id()) :: :ok | {:error, String.t()}
  def perform(ship_type_id) do
    ship_type = Types.get_ship_type!(ship_type_id)
    Types.delete_ship_type(ship_type)
  end
end
