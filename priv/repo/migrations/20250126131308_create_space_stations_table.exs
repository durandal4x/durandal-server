defmodule Durandal.Repo.Migrations.CreateSpaceStationsTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:space_stations, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:name, :string)
      add(:team_id, references(:player_teams, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:system_id, references(:space_systems, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:position, {:array, :integer})
      add(:velocity, {:array, :integer})

      add(:orbiting_id, references(:space_system_objects, on_delete: :nothing, type: :uuid),
        type: :uuid
      )

      add(:universe_id, references(:game_universes, on_delete: :nothing, type: :uuid),
        type: :uuid
      )

      add(:orbit_distance, :integer)
      add(:orbit_clockwise, :boolean)
      add(:orbit_period, :integer)

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists(index(:space_stations, [:orbiting_id]))
    create_if_not_exists(index(:space_stations, [:team_id]))
    create_if_not_exists(index(:space_stations, [:system_id]))
    create_if_not_exists(index(:space_stations, [:universe_id]))

    create_if_not_exists table(:space_station_modules, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:station_id, references(:space_stations, on_delete: :nothing, type: :uuid), type: :uuid)

      add(:type_id, references(:station_module_types, on_delete: :nothing, type: :uuid),
        type: :uuid
      )

      add(:universe_id, references(:game_universes, on_delete: :nothing, type: :uuid),
        type: :uuid
      )

      add(:build_progress, :integer)
      add(:health, :integer)

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists(index(:space_station_modules, [:station_id]))
    create_if_not_exists(index(:space_station_modules, [:type_id]))
    create_if_not_exists(index(:space_station_modules, [:universe_id]))
  end
end
