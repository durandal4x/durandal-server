defmodule Durandal.Space.ShipQueries do
  @moduledoc false
  use DurandalMacros, :queries
  alias Durandal.Space.Ship
  require Logger

  @spec ship_query(Durandal.query_args()) :: Ecto.Query.t()
  def ship_query(args) do
    query = from(ships in Ship)

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
    from ships in query,
      where: ships.id in ^List.wrap(id)
  end

  def _where(query, :name, name) do
    from objects in query,
      where: objects.name in ^List.wrap(name)
  end

  def _where(query, :team_id, team_id) do
    from objects in query,
      where: objects.team_id in ^List.wrap(team_id)
  end

  def _where(query, :type_id, type_id) do
    from objects in query,
      where: objects.type_id in ^List.wrap(type_id)
  end

  def _where(query, :system_id, system_id) do
    from objects in query,
      where: objects.system_id in ^List.wrap(system_id)
  end

  def _where(query, :has_position, position) do
    from(objects in query,
      where: ^position in objects.position
    )
  end

  def _where(query, :not_has_position, position) do
    from(objects in query,
      where: ^position not in objects.position
    )
  end

  def _where(query, :has_velocity, velocity) do
    from(objects in query,
      where: ^velocity in objects.velocity
    )
  end

  def _where(query, :not_has_velocity, velocity) do
    from(objects in query,
      where: ^velocity not in objects.velocity
    )
  end

  def _where(query, :orbiting_id, orbiting_id) do
    from objects in query,
      where: objects.orbiting_id in ^List.wrap(orbiting_id)
  end

  def _where(query, :orbit_distance, orbit_distance) do
    from objects in query,
      where: objects.orbit_distance in ^List.wrap(orbit_distance)
  end

  def _where(query, :orbit_clockwise, orbit_clockwise) do
    from objects in query,
      where: objects.orbit_clockwise in ^List.wrap(orbit_clockwise)
  end

  def _where(query, :orbit_period, orbit_period) do
    from objects in query,
      where: objects.orbit_period in ^List.wrap(orbit_period)
  end

  def _where(query, :build_progress, build_progress) do
    from objects in query,
      where: objects.build_progress in ^List.wrap(build_progress)
  end

  def _where(query, :health, health) do
    from objects in query,
      where: objects.health in ^List.wrap(health)
  end

  def _where(query, :inserted_after, timestamp) do
    from ships in query,
      where: ships.inserted_at >= ^timestamp
  end

  def _where(query, :inserted_before, timestamp) do
    from ships in query,
      where: ships.inserted_at < ^timestamp
  end

  def _where(query, :updated_after, timestamp) do
    from ships in query,
      where: ships.updated_at >= ^timestamp
  end

  def _where(query, :updated_before, timestamp) do
    from ships in query,
      where: ships.updated_at < ^timestamp
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
    from(users in query,
      order_by: [asc: users.name]
    )
  end

  def _order_by(query, "Name (Z-A)") do
    from(users in query,
      order_by: [desc: users.name]
    )
  end

  def _order_by(query, "Newest first") do
    from ships in query,
      order_by: [desc: ships.inserted_at]
  end

  def _order_by(query, "Oldest first") do
    from ships in query,
      order_by: [asc: ships.inserted_at]
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

  def _preload(query, :team) do
    from objects in query,
      left_join: player_teams in assoc(objects, :team),
      preload: [team: player_teams]
  end

  def _preload(query, :type) do
    from objects in query,
      left_join: ship_types in assoc(objects, :type),
      preload: [type: ship_types]
  end

  def _preload(query, :orbiting) do
    from objects in query,
      left_join: space_system_objects in assoc(objects, :orbiting),
      preload: [orbiting: space_system_objects]
  end
end
