defmodule Durandal.Space.DeleteSystemObjectTask do
  alias Durandal.Space

  @spec perform(Durandal.system_object_id()) :: :ok | {:error, String.t()}
  def perform(system_object_id) do
    system_object = Space.get_system_object!(system_object_id)
    Space.delete_system_object(system_object)
  end
end
