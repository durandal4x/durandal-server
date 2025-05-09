defmodule Durandal.Engine do
  @moduledoc """
  The Engine module is responsible for the main functionality of the Durandal, mostly
  in terms of processing the in-game events.

  Eval and execution pipeline
  Command -> Instruction -> Action -> Effect

  Some definitions
  **Actions:** Something an entity will do (e.g. thrust towards a point), they are typically very simple and limited.
  **Command:** A player written order for a unit to complete, they can be both low level (travel to a specific location) and high level (ferry goods G from point A to point B)
  **Effect:** A result of an action and applied by the relevant systems in the game (e.g. acceleration results in a new velocity)
  **Instructions:** Unit written orders derived from player commands, much lower level and intended to be easier to transform into actions.
  """

  require Logger

  @doc """
  The stages run through each tick
  """
  def evaluation_stages do
    ~w(player_commands internal_instructions apply_actions transfer physics combat player_commands_post_process)a
  end

  @doc """
  Returns a map of stage to a map of system modules
  """
  @spec systems_by_stage() :: %{atom() => %{String.t() => module()}}
  def systems_by_stage() do
    system_lookup()
    |> Enum.group_by(fn {_name, m} ->
      m.stage()
    end)
    |> Map.new(fn {key, modules} ->
      {key, Map.new(modules)}
    end)
  end

  @doc """
  A map of %{system name => system module) for all systems
  """
  @spec system_lookup() :: %{String.t() => module()}
  def system_lookup() do
    case Cachex.get(:durandal_system_modules, "_complete") do
      {:ok, nil} ->
        {:ok, lookup} = build_system_lookup()
        lookup

      {:ok, lookup} ->
        lookup
    end
  end

  @spec get_system(String.t()) :: {:ok, nil | module()}
  def get_system(name) do
    Cachex.get(:durandal_system_modules, name)
  end

  @doc """
  Iterates through all the systems using the SystemMacro behaviour and stores them for lookup.
  """
  @spec build_system_lookup() :: {:ok, %{String.t() => module()}}
  def build_system_lookup() do
    {:ok, module_list} = :application.get_key(:durandal, :modules)

    # First, build the lookup from modules implementing this behaviour
    # and exporting a name/0 function
    lookup =
      module_list
      |> Enum.filter(fn m ->
        Code.ensure_loaded(m)

        # We got a weird bug sometimes where an old module got picked up by the module list
        # but would then error on the next part, the solution was to check if Code was loaded or not
        system_macro? =
          case Code.loaded?(m) && m.__info__(:attributes)[:behaviour] do
            false -> false
            [] -> false
            nil -> false
            b -> Enum.member?(b, Durandal.Engine.SystemMacro)
          end

        system_macro? and function_exported?(m, :name, 0)
      end)
      |> Map.new(fn m ->
        {m.name(), m}
      end)

    old = Cachex.get!(:durandal_system_modules, "_all") || []

    # Store all keys, we'll use it later for removing old ones
    Cachex.put(:durandal_system_modules, "_all", lookup)

    # Now store our lookups
    lookup
    |> Enum.each(fn {key, func} ->
      Cachex.put(:durandal_system_modules, key, func)
    end)

    # And a copy of the complete lookup since we'll want to pull that back sometimes rather than doing several round trips
    Cachex.put(:durandal_system_modules, "_complete", lookup)

    # Delete out-dated keys
    old
    |> Enum.reject(fn old_key ->
      Map.has_key?(lookup, old_key)
    end)
    |> Enum.each(fn old_key ->
      Cachex.del(:durandal_system_modules, old_key)
    end)

    {:ok, lookup}
  end

  @doc """
  Pass on actions for later systems

  Example:

    add_action(context, ship_id, [:velocity], [])
  """
  @spec add_action(map(), Ecto.UUID.t(), list(atom()), map()) :: map()
  def add_action(context, subject_id, tags, action) do
    id = Ecto.UUID.generate()

    # Add the action id to the ref lookup
    context = put_in(context[:actions][id], action)

    # Reference the id in subject_id
    v = [id | Map.get(context.actions_by_subject_id, subject_id, [])]
    context = put_in(context[:actions_by_subject_id][subject_id], v)

    # Reference it per tag, if tags are empty skip this step
    if Enum.empty?(tags) do
      context
    else
      v =
        tags
        |> Map.new(fn tag ->
          {tag, [id | Map.get(context.actions_by_tag, tag, [])]}
        end)

      new_actions_by_tag = Map.merge(context[:actions_by_tag], v)

      %{context | actions_by_tag: new_actions_by_tag}
    end
  end

  @spec get_actions_by_tag(map(), atom) :: [map()]
  def get_actions_by_tag(context, tag) do
    Map.get(context.actions_by_tag, tag, [])
    |> Enum.map(fn id ->
      Map.get(context.actions, id)
    end)
  end

  @spec get_actions_by_subject_id(map(), atom) :: [map()]
  def get_actions_by_subject_id(context, subject_id) do
    Map.get(context.actions_by_subject_id, subject_id, [])
    |> Enum.map(fn id ->
      Map.get(context.actions, id)
    end)
  end

  def add_command_logs(context, command_id, logs) do
    put_in(context, [:command_logs, command_id], logs)
  end

  def add_systems_logs(context, system_id, logs) do
    put_in(context, [:systems_logs, system_id], logs)
  end
end
