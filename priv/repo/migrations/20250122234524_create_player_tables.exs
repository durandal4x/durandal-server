defmodule Durandal.Repo.Migrations.CreatePlayerTeamsTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:player_teams, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:name, :string)

      add(:universe_id, references(:game_universes, on_delete: :nothing, type: :uuid),
        type: :uuid
      )

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists table(:player_team_members, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:roles, {:array, :string})
      add(:team_id, references(:player_teams, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists table(:player_commands, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:command_type, :string)
      add(:subject_type, :string)
      add(:subject_id, :uuid)
      add(:ordering, :integer)
      add(:contents, :jsonb)
      add(:team_id, references(:player_teams, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)

      timestamps(type: :utc_datetime_usec)
    end
  end
end
