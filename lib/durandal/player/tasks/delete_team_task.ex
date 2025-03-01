defmodule Durandal.Player.DeleteTeamTask do
  alias Durandal.Player

  @spec perform(Durandal.team_id()) :: :ok | {:error, String.t()}
  def perform(team_id) do
    team = Player.get_team!(team_id)
    Player.delete_team(team)
  end
end
