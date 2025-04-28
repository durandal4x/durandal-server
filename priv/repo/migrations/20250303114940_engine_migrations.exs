defmodule Durandal.Repo.Migrations.EngineMigrations do
  use Ecto.Migration

  def change do
    alter table(:game_universes) do
      add :last_tick, :utc_datetime_usec
      add :next_tick, :utc_datetime_usec
      add :tick_schedule, :string
      add :tick_seconds, :integer
    end

    alter table(:player_teams) do
      add :member_count, :integer
    end

    alter table(:player_team_members) do
      add(:universe_id, references(:game_universes, on_delete: :nothing, type: :uuid),
        type: :uuid
      )

      add :enabled?, :boolean
    end

    alter table(:space_ships) do
      remove :orbit_distance

      add(:docked_with_id, references(:space_stations, on_delete: :nothing, type: :uuid),
        type: :uuid
      )

      remove(:position)
      add(:position, {:array, :bigint})
    end

    create_if_not_exists(index(:space_ships, [:docked_with_id]))

    alter table(:space_stations) do
      remove :orbit_distance
      remove(:position)
      add(:position, {:array, :bigint})
    end

    alter table(:space_system_objects) do
      remove :orbit_distance
      remove(:position)
      add(:position, {:array, :bigint})
    end

    alter table(:player_commands) do
      add(:progress, :integer)
      add(:outcome, :jsonb)
    end
  end
end
