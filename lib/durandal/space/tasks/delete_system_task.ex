defmodule Durandal.Space.DeleteSystemTask do
  alias Durandal.Space

  @spec perform(Durandal.system_id()) :: :ok | {:error, String.t()}
  def perform(system_id) do
    system = Space.get_system!(system_id)
    Space.delete_system(system)
  end
end
