defmodule Durandal.Game.DeleteUniverseTask do
  @moduledoc """
  Deletes a universe and all entities within it
  """
  alias Durandal.{Repo, Game, Player}
  import Ecto.UUID, only: [dump!: 1]

  @spec perform(Durandal.Game.Universe.id()) :: :ok | {:error, String.t()}
  def perform(universe_id) do
    Game.UniverseLib.stop_universe_supervisor(universe_id)
    universe = Game.get_universe!(universe_id)

    Repo.transaction(fn ->
      team_ids =
        Player.list_teams(where: [universe_id: universe_id], select: [:id])
        |> Enum.map(& &1.id)

      team_member_ids =
        Player.list_team_members(where: [universe_id: universe_id], select: [:team_id, :user_id])
        |> Enum.map(fn tm -> "#{tm.team_id}:#{tm.user_id}" end)

      team_query = "SELECT id FROM player_teams WHERE universe_id = $1"
      system_query = "SELECT id FROM space_systems WHERE universe_id = $1"
      station_query = "SELECT id FROM space_stations WHERE system_id IN (#{system_query})"

      # Resources
      [
        "resources_simple_station_module_instances",
        "resources_simple_ship_instances",
        "resources_composite_station_module_instances",
        "resources_composite_ship_instances",
        "resources_composite_types",
        "resources_simple_types"
      ]
      |> Enum.each(fn table ->
        query = "DELETE FROM #{table} WHERE universe_id = $1"
        {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [dump!(universe_id)])
      end)

      # Commands
      query = "DELETE FROM player_commands WHERE universe_id = $1"
      {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [dump!(universe_id)])

      # Ships
      query = "DELETE FROM space_ships WHERE system_id IN (#{system_query})"
      {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [dump!(universe_id)])

      # Stations
      query = "DELETE FROM space_station_modules WHERE station_id IN (#{station_query})"
      {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [dump!(universe_id)])

      query = "DELETE FROM space_stations WHERE system_id IN (#{system_query})"
      {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [dump!(universe_id)])

      # System objects
      query = "DELETE FROM space_system_objects WHERE system_id IN (#{system_query})"
      {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [dump!(universe_id)])

      # Systems
      query = "DELETE FROM space_systems WHERE universe_id = $1"
      {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [dump!(universe_id)])

      # Types
      query = "DELETE FROM ship_types WHERE universe_id = $1"
      {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [dump!(universe_id)])

      query = "DELETE FROM station_module_types WHERE universe_id = $1"
      {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [dump!(universe_id)])

      query = "DELETE FROM system_object_types WHERE universe_id = $1"
      {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [dump!(universe_id)])

      # Teams
      query = "DELETE FROM player_team_members WHERE team_id IN (#{team_query})"
      {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [dump!(universe_id)])

      query = "DELETE FROM player_teams WHERE universe_id = $1"
      {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [dump!(universe_id)])

      # Clear caches
      Durandal.invalidate_cache(:team_by_team_id_cache, team_ids)
      Durandal.invalidate_cache(:team_member_by_id_cache, team_member_ids)

      # Now delete the actual universe
      Game.delete_universe(universe)
    end)
  end
end
