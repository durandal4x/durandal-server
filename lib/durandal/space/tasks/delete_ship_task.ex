defmodule Durandal.Space.DeleteShipTask do
  @moduledoc """
  Deletes a universe and all entities within it
  """
  alias Durandal.{Repo, Space}
  import Ecto.UUID, only: [dump!: 1]

  @spec perform(Space.Ship.t()) :: :ok | {:error, String.t()}
  def perform(%Space.Ship{} = ship) do
    Repo.transaction(fn ->
      # Commands
      query = "DELETE FROM player_commands WHERE subject_id = $1"
      {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [dump!(ship.id)])

      # Transfers
      query = "DELETE FROM space_ship_transfers WHERE ship_id = $1"
      {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [dump!(ship.id)])

      # # Clear caches
      # Durandal.invalidate_cache(:team_by_team_id_cache, team_ids)
      # Durandal.invalidate_cache(:team_member_by_id_cache, team_member_ids)

      # Now delete the actual universe
      Space.delete_ship(ship)
    end)
  end
end
