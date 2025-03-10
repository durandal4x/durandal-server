defmodule Durandal.Repo.Migrations.EngineMigrations do
  use Ecto.Migration

  def change do
    alter table(:game_universes) do
      add :last_tick, :utc_datetime_usec
      add :next_tick, :utc_datetime_usec
      add :tick_schedule, :string
      add :tick_seconds, :integer
    end

    alter table(:space_ships) do
      remove :orbit_distance
    end

    alter table(:space_stations) do
      remove :orbit_distance
    end

    alter table(:space_system_objects) do
      remove :orbit_distance
    end
  end
end
