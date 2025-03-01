defmodule Durandal.Game.DeleteUniverseTask do
  @moduledoc """
  Deletes a universe and all entities within it
  """
  alias Durandal.{Repo, Game}
  import Ecto.UUID, only: [dump!: 1]

  @spec perform(Durandal.Game.Universe.id()) :: :ok | {:error, String.t()}
  def perform(universe_id) do
    universe = Game.get_universe!(universe_id)

    Repo.transaction(fn ->
      # team_query = "SELECT id FROM player_teams WHERE universe_id = $1"
      system_query = "SELECT id FROM space_systems WHERE universe_id = $1"
      station_query = "SELECT id FROM space_stations WHERE system_id IN (#{system_query})"

      # Ships
      query = "DELETE FROM space_ships WHERE system_id IN (#{system_query})"
      {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [dump!(universe_id)])

      # Station modules
      query = "DELETE FROM space_system_objects WHERE system_id IN (#{system_query})"
      {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [dump!(universe_id)])

      # Stations
      query = "DELETE FROM space_station_modules WHERE station_id IN (#{station_query})"
      {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [dump!(universe_id)])

      query = "DELETE FROM space_stations WHERE system_id IN (#{system_query})"
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
      query = "DELETE FROM player_teams WHERE universe_id = $1"
      {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [dump!(universe_id)])

      # Now delete the actual universe
      Game.delete_universe(universe)
    end)
  end
end
