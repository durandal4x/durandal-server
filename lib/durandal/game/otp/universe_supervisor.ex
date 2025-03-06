defmodule Durandal.Game.UniverseSupervisor do
  use Supervisor
  alias Durandal.Game.UniverseLib

  def start_link(init_arg) do
    %{universe_id: universe_id} = init_arg
    name = UniverseLib.supervisor_name(universe_id)

    Horde.Registry.register(
      Durandal.GameRegistry,
      universe_id,
      universe_id
    )

    Supervisor.start_link(__MODULE__, init_arg, name: name)
  end

  @impl true
  def init(%{universe_id: universe_id} = _init_arg) do
    children = [
      {DynamicSupervisor,
       strategy: :one_for_one, name: UniverseLib.dynamic_supervisor_name(universe_id)},
      {Task.Supervisor, name: UniverseLib.task_supervisor_name(universe_id)},
      {Horde.Registry,
       [keys: :unique, members: :auto, name: UniverseLib.registry_name(universe_id)]},
      %{
        id: UniverseLib.server_name(universe_id),
        start: {Durandal.Game.UniverseServer, :start_link, [%{universe_id: universe_id}]}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
