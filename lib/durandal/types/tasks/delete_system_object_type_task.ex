defmodule Durandal.Types.DeleteSystemObjectTypeTask do
  alias Durandal.Types

  @spec perform(Durandal.system_object_type_id()) :: :ok | {:error, String.t()}
  def perform(system_object_type_id) do
    system_object_type = Types.get_system_object_type!(system_object_type_id)
    Types.delete_system_object_type(system_object_type)
  end
end
