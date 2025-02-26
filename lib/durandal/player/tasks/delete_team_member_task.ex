defmodule Durandal.Player.DeleteTeamMemberTask do
  alias Durandal.Player
  # import Ecto.UUID, only: [dump!: 1]

  @spec perform(Durandal.team_id(), Durandal.user_id()) :: :ok | {:error, String.t()}
  def perform(team_id, user_id) do
    team_member = Player.get_team_member!(team_id, user_id)
    Player.delete_team_member(team_member)
  end
end
