defmodule Durandal.Game.UniverseSupervisor do
  use Supervisor
  alias Durandal.Game.UniverseLib

  def start_link(init_arg) do
    %{universe_id: universe_id} = init_arg
    name = UniverseLib.supervisor_name(universe_id)

    Supervisor.start_link(__MODULE__, init_arg, name: name)
  end

  @impl true
  def init(%{universe_id: universe_id} = _init_arg) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: UniverseLib.dynamic_supervisor_name(universe_id)},
      {Horde.Registry, [keys: :unique, members: :auto, name: UniverseLib.registry_name(universe_id)]},
      {Durandal.Game.UniverseServer, %{universe_id: universe_id}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
