defmodule Durandal.Space.StationQueries do
  @moduledoc false
  use DurandalMacros, :queries
  alias Durandal.Space.Station
  require Logger

  @spec station_query(Durandal.query_args()) :: Ecto.Query.t()
  def station_query(args) do
    query = from(stations in Station)

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
    from stations in query,
      where: stations.id in ^List.wrap(id)
  end

  def _where(query, :id_not, id) do
    from stations in query,
      where: stations.id not in ^List.wrap(id)
  end

  def _where(query, :name, name) do
    from stations in query,
      where: stations.name in ^List.wrap(name)
  end

  def _where(query, :team_id, team_id) do
    from stations in query,
      where: stations.team_id in ^List.wrap(team_id)
  end

  def _where(query, :universe_id, universe_id) do
    from stations in query,
      where: stations.universe_id in ^List.wrap(universe_id)
  end

  def _where(query, :system_id, system_id) do
    from stations in query,
      where: stations.system_id in ^List.wrap(system_id)
  end

  def _where(query, :has_position, position) do
    from(stations in query,
      where: ^position in stations.position
    )
  end

  def _where(query, :not_has_position, position) do
    from(stations in query,
      where: ^position not in stations.position
    )
  end

  def _where(query, :has_velocity, velocity) do
    from(stations in query,
      where: ^velocity in stations.velocity
    )
  end

  def _where(query, :not_has_velocity, velocity) do
    from(stations in query,
      where: ^velocity not in stations.velocity
    )
  end

  def _where(query, :orbiting_id, :not_nil) do
    from stations in query,
      where: not is_nil(stations.orbiting_id)
  end

  def _where(query, :orbiting_id, :is_nil) do
    from stations in query,
      where: is_nil(stations.orbiting_id)
  end

  def _where(query, :orbiting_id, orbiting_id) do
    from stations in query,
      where: stations.orbiting_id in ^List.wrap(orbiting_id)
  end

  def _where(query, :orbit_clockwise, orbit_clockwise) do
    from stations in query,
      where: stations.orbit_clockwise in ^List.wrap(orbit_clockwise)
  end

  def _where(query, :orbit_period, orbit_period) do
    from stations in query,
      where: stations.orbit_period in ^List.wrap(orbit_period)
  end

  def _where(query, :inserted_after, timestamp) do
    from stations in query,
      where: stations.inserted_at >= ^timestamp
  end

  def _where(query, :inserted_before, timestamp) do
    from stations in query,
      where: stations.inserted_at < ^timestamp
  end

  def _where(query, :updated_after, timestamp) do
    from stations in query,
      where: stations.updated_at >= ^timestamp
  end

  def _where(query, :updated_before, timestamp) do
    from stations in query,
      where: stations.updated_at < ^timestamp
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
    from stations in query,
      order_by: [desc: stations.inserted_at]
  end

  def _order_by(query, "Oldest first") do
    from stations in query,
      order_by: [asc: stations.inserted_at]
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
    from stations in query,
      left_join: player_teams in assoc(stations, :team),
      preload: [team: player_teams]
  end

  def _preload(query, :system) do
    from stations in query,
      left_join: space_systems in assoc(stations, :system),
      preload: [system: space_systems]
  end

  def _preload(query, :orbiting) do
    from stations in query,
      left_join: space_system_stations in assoc(stations, :orbiting),
      preload: [orbiting: space_system_stations]
  end

  def _preload(query, :modules_with_types) do
    from(stations in query,
      left_join: modules in assoc(stations, :modules),
      left_join: types in assoc(modules, :type),
      preload: [modules: {modules, type: types}]
    )
  end

  def _preload(query, :docked_ships_with_types) do
    from(stations in query,
      left_join: docked_ships in assoc(stations, :docked_ships),
      left_join: types in assoc(docked_ships, :type),
      preload: [docked_ships: {docked_ships, type: types}]
    )
  end

  def _preload(query, :universe) do
    from stations in query,
      left_join: game_universes in assoc(stations, :universe),
      preload: [universe: game_universes]
  end

  def _preload(query, :all_commands) do
    from stations in query,
      left_join: commands in assoc(stations, :commands),
      on: commands.subject_id == stations.id,
      on: commands.subject_type == "station",
      preload: [commands: commands]
  end

  def _preload(query, :incomplete_commands) do
    from stations in query,
      left_join: commands in assoc(stations, :commands),
      on: commands.subject_id == stations.id,
      on: commands.subject_type == "station",
      on: commands.progress < 100,
      preload: [commands: commands]
  end
end
