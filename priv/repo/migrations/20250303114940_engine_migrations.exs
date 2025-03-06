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
  end
end

# Steps to rollback the migration even if partially applied, will be removed from the final merge
# DELETE FROM schema_migrations WHERE version = '20250303114940';
# ALTER TABLE game_universes DROP COLUMN last_tick;
# ALTER TABLE game_universes DROP COLUMN next_tick;
# ALTER TABLE game_universes DROP COLUMN tick_schedule;
# ALTER TABLE game_universes DROP COLUMN tick_seconds;

# ALTER TABLE player_teams DROP COLUMN member_count;
# ALTER TABLE player_team_members DROP COLUMN "active?";
# ALTER TABLE player_team_members DROP COLUMN "enabled?";
# ALTER TABLE player_team_members DROP COLUMN universe_id;

# ALTER TABLE space_ships ADD COLUMN orbit_distance INTEGER;
# ALTER TABLE space_stations ADD COLUMN orbit_distance INTEGER;
# ALTER TABLE space_system_objects ADD COLUMN orbit_distance INTEGER;

# ALTER TABLE space_ships DROP COLUMN docked_with_id;
