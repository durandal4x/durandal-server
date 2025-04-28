defmodule Durandal.Space.SystemObjectQueries do
  @moduledoc false
  use DurandalMacros, :queries
  alias Durandal.Space.SystemObject
  require Logger

  @spec system_object_query(Durandal.query_args()) :: Ecto.Query.t()
  def system_object_query(args) do
    query = from(system_objects in SystemObject)

    query
    |> do_where(id: args[:id])
    |> do_where(args[:where])
    |> do_where(args[:search])
    |> do_preload(args[:preload])
    |> do_order_by(args[:order_by])
    |> QueryHelper.query_select(args[:select])
    |> QueryHelper.limit_query(args[:limit] || 50)
  end

  @spec do_where(Ecto.Query.t(), list | map | nil) :: Ecto.Query.t()
  defp do_where(query, nil), do: query

  defp do_where(query, params) do
    params
    |> Enum.reduce(query, fn {key, value}, query_acc ->
      _where(query_acc, key, value)
    end)
  end

  @spec _where(Ecto.Query.t(), Atom.t(), any()) :: Ecto.Query.t()
  def _where(query, _, ""), do: query
  def _where(query, _, nil), do: query

  def _where(query, :id, id) do
    from system_objects in query,
      where: system_objects.id in ^List.wrap(id)
  end

  def _where(query, :name, name) do
    from system_objects in query,
      where: system_objects.name in ^List.wrap(name)
  end

  def _where(query, :type_id, type_id) do
    from system_objects in query,
      where: system_objects.type_id in ^List.wrap(type_id)
  end

  def _where(query, :universe_id, universe_id) do
    from system_objects in query,
      where: system_objects.universe_id in ^List.wrap(universe_id)
  end

  def _where(query, :system_id, system_id) do
    from system_objects in query,
      where: system_objects.system_id in ^List.wrap(system_id)
  end

  def _where(query, :has_position, position) do
    from(system_objects in query,
      where: ^position in system_objects.position
    )
  end

  def _where(query, :not_has_position, position) do
    from(system_objects in query,
      where: ^position not in system_objects.position
    )
  end

  def _where(query, :has_velocity, velocity) do
    from(system_objects in query,
      where: ^velocity in system_objects.velocity
    )
  end

  def _where(query, :not_has_velocity, velocity) do
    from(system_objects in query,
      where: ^velocity not in system_objects.velocity
    )
  end

  def _where(query, :orbiting_id, :not_nil) do
    from system_objects in query,
      where: not is_nil(system_objects.orbiting_id)
  end

  def _where(query, :orbiting_id, :is_nil) do
    from system_objects in query,
      where: is_nil(system_objects.orbiting_id)
  end

  def _where(query, :orbiting_id, orbiting_id) do
    from system_objects in query,
      where: system_objects.orbiting_id in ^List.wrap(orbiting_id)
  end

  def _where(query, :orbit_clockwise, orbit_clockwise) do
    from system_objects in query,
      where: system_objects.orbit_clockwise in ^List.wrap(orbit_clockwise)
  end

  def _where(query, :orbit_period, orbit_period) do
    from system_objects in query,
      where: system_objects.orbit_period in ^List.wrap(orbit_period)
  end

  def _where(query, :inserted_after, timestamp) do
    from system_objects in query,
      where: system_objects.inserted_at >= ^timestamp
  end

  def _where(query, :inserted_before, timestamp) do
    from system_objects in query,
      where: system_objects.inserted_at < ^timestamp
  end

  def _where(query, :updated_after, timestamp) do
    from system_objects in query,
      where: system_objects.updated_at >= ^timestamp
  end

  def _where(query, :updated_before, timestamp) do
    from system_objects in query,
      where: system_objects.updated_at < ^timestamp
  end

  @spec do_order_by(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
  defp do_order_by(query, nil), do: query

  defp do_order_by(query, params) do
    params
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _order_by(query_acc, key)
    end)
  end

  @spec _order_by(Ecto.Query.t(), any()) :: Ecto.Query.t()

  def _order_by(query, "Name (A-Z)") do
    from(system_objects in query,
      order_by: [asc: system_objects.name]
    )
  end

  def _order_by(query, "Name (Z-A)") do
    from(system_objects in query,
      order_by: [desc: system_objects.name]
    )
  end

  def _order_by(query, "Newest first") do
    from system_objects in query,
      order_by: [desc: system_objects.inserted_at]
  end

  def _order_by(query, "Oldest first") do
    from system_objects in query,
      order_by: [asc: system_objects.inserted_at]
  end

  @spec do_preload(Ecto.Query.t(), List.t() | nil) :: Ecto.Query.t()
  defp do_preload(query, nil), do: query

  defp do_preload(query, preloads) do
    preloads
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _preload(query_acc, key)
    end)
  end

  def _preload(query, :type) do
    from system_objects in query,
      left_join: system_object_types in assoc(system_objects, :type),
      preload: [type: system_object_types]
  end

  def _preload(query, :system) do
    from system_objects in query,
      left_join: space_systems in assoc(system_objects, :system),
      preload: [system: space_systems]
  end

  def _preload(query, :orbiting) do
    from system_objects in query,
      left_join: space_system_objects in assoc(system_objects, :orbiting),
      preload: [orbiting: space_system_objects]
  end

  def _preload(query, :universe) do
    from system_objects in query,
      left_join: game_universes in assoc(system_objects, :universe),
      preload: [universe: game_universes]
  end
end
