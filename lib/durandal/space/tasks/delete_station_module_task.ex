defmodule Durandal.Space.DeleteStationModuleTask do
  alias Durandal.Space

  @spec perform(Durandal.station_module_id()) :: :ok | {:error, String.t()}
  def perform(station_module_id) do
    station_module = Space.get_station_module!(station_module_id)
    Space.delete_station_module(station_module)
  end
end
