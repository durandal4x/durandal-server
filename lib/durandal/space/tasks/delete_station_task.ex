defmodule Durandal.Space.DeleteStationTask do
  alias Durandal.Space

  @spec perform(Durandal.station_id()) :: :ok | {:error, String.t()}
  def perform(station_id) do
    station = Space.get_station!(station_id)
    Space.delete_station(station)
  end
end
