defmodule Durandal.Types.DeleteStationModuleTypeTask do
  alias Durandal.Types

  @spec perform(Durandal.station_module_type_id()) :: :ok | {:error, String.t()}
  def perform(station_module_type_id) do
    station_module_type = Types.get_station_module_type!(station_module_type_id)
    Types.delete_station_module_type(station_module_type)
  end
end
