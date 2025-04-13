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

  def _where(query, :id_not, id) do
    from ships in query,
      where: ships.id not in ^List.wrap(id)
  end

  def _where(query, :name, name) do
    from ships in query,
      where: ships.name in ^List.wrap(name)
  end

  def _where(query, :team_id, team_id) do
    from ships in query,
      where: ships.team_id in ^List.wrap(team_id)
  end

  def _where(query, :universe_id, universe_id) do
    from ships in query,
      where: ships.universe_id in ^List.wrap(universe_id)
  end

  def _where(query, :type_id, type_id) do
    from ships in query,
      where: ships.type_id in ^List.wrap(type_id)
  end

  def _where(query, :system_id, system_id) do
    from ships in query,
      where: ships.system_id in ^List.wrap(system_id)
  end

  def _where(query, :has_position, position) do
    from(ships in query,
      where: ^position in ships.position
    )
  end

  def _where(query, :not_has_position, position) do
    from(ships in query,
      where: ^position not in ships.position
    )
  end

  def _where(query, :has_velocity, velocity) do
    from(ships in query,
      where: ^velocity in ships.velocity
    )
  end

  def _where(query, :not_has_velocity, velocity) do
    from(ships in query,
      where: ^velocity not in ships.velocity
    )
  end

  def _where(query, :orbiting_id, :not_nil) do
    from ships in query,
      where: not is_nil(ships.orbiting_id)
  end

  def _where(query, :orbiting_id, :is_nil) do
    from ships in query,
      where: is_nil(ships.orbiting_id)
  end

  def _where(query, :orbiting_id, orbiting_id) do
    from ships in query,
      where: ships.orbiting_id in ^List.wrap(orbiting_id)
  end

  def _where(query, :orbit_clockwise, orbit_clockwise) do
    from ships in query,
      where: ships.orbit_clockwise in ^List.wrap(orbit_clockwise)
  end

  def _where(query, :orbit_period, orbit_period) do
    from ships in query,
      where: ships.orbit_period in ^List.wrap(orbit_period)
  end

  def _where(query, :build_progress, build_progress) do
    from ships in query,
      where: ships.build_progress in ^List.wrap(build_progress)
  end

  def _where(query, :docked_with_id, :not_nil) do
    from ships in query,
      where: not is_nil(ships.docked_with_id)
  end

  def _where(query, :docked_with_id, :is_nil) do
    from ships in query,
      where: is_nil(ships.docked_with_id)
  end

  def _where(query, :docked_with_id, docked_with_id) do
    from ships in query,
      where: ships.docked_with_id in ^List.wrap(docked_with_id)
  end

  def _where(query, :transferring?, true) do
    from ships in query,
      where: not is_nil(ships.current_transfer_id)
  end

  def _where(query, :transferring?, false) do
    from ships in query,
      where: is_nil(ships.current_transfer_id)
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
    from ships in query,
      left_join: player_teams in assoc(ships, :team),
      preload: [team: player_teams]
  end

  def _preload(query, :system) do
    from ships in query,
      left_join: space_systems in assoc(ships, :system),
      preload: [system: space_systems]
  end

  def _preload(query, :type) do
    from ships in query,
      left_join: ship_types in assoc(ships, :type),
      preload: [type: ship_types]
  end

  def _preload(query, :orbiting) do
    from ships in query,
      left_join: space_system_objects in assoc(ships, :orbiting),
      preload: [orbiting: space_system_objects]
  end

  def _preload(query, :transfer) do
    from ships in query,
      left_join: space_ship_transfers in assoc(ships, :current_transfer),
      preload: [current_transfer: space_ship_transfers]
  end

  def _preload(query, :transfer_with_destination) do
    from ships in query,
      left_join: space_ship_transfers in assoc(ships, :current_transfer),
      left_join: space_stations in assoc(space_ship_transfers, :to_station),
      left_join: space_system_objects in assoc(space_ship_transfers, :to_system_object),
      preload: [
        current_transfer:
          {space_ship_transfers,
           to_station: space_stations, to_system_object: space_system_objects}
      ]

    # query = from universes in Durandal.Game.Universe,
    #   join: teams in assoc(universes, :teams),
    #   join: team_members in assoc(teams, :team_members),
    #     where: team_members.user_id == ^user_id,
    #   where: team_members.enabled? == true,
    #   preload: [teams: {teams, team_members: team_members}],
    #   order_by: [asc: universes.name]
  end

  def _preload(query, :docked_with) do
    from ships in query,
      left_join: space_stations in assoc(ships, :docked_with),
      preload: [docked_with: space_stations]
  end

  def _preload(query, :universe) do
    from ships in query,
      left_join: game_universes in assoc(ships, :universe),
      preload: [universe: game_universes]
  end

  def _preload(query, :all_commands) do
    from ships in query,
      left_join: commands in assoc(ships, :commands),
      on: commands.subject_id == ships.id,
      on: commands.subject_type == "ship",
      order_by: [asc: commands.ordering],
      preload: [commands: commands]
  end

  def _preload(query, :incomplete_commands) do
    from ships in query,
      left_join: commands in assoc(ships, :commands),
      on: commands.subject_id == ships.id,
      on: commands.subject_type == "ship",
      on: commands.completed? == false,
      order_by: [asc: commands.ordering],
      preload: [commands: commands]
  end
end
