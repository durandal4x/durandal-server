defmodule Durandal.Repo.Migrations.CreateResources do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:resources_simple_types, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:name, :string, null: false)
      add(:mass, :integer, null: false)
      add(:volume, :integer, null: false)
      add(:tags, {:array, :string})

      add(:universe_id, references(:game_universes, on_delete: :nothing, type: :uuid),
        type: :uuid,
        null: false
      )

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists table(:resources_simple_station_module_instances,
                           primary_key: false
                         ) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:type_id, references(:resources_simple_types, on_delete: :nothing, type: :uuid),
        type: :uuid,
        null: false
      )

      add(:quantity, :integer, null: false)

      add(:universe_id, references(:game_universes, on_delete: :nothing, type: :uuid),
        type: :uuid,
        null: false
      )

      add(:team_id, references(:player_teams, on_delete: :nothing, type: :uuid), type: :uuid)

      add(
        :station_module_id,
        references(:space_station_modules, on_delete: :nothing, type: :uuid),
        type: :uuid,
        null: false
      )

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists table(:resources_simple_ship_instances, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:type_id, references(:resources_simple_types, on_delete: :nothing, type: :uuid),
        type: :uuid,
        null: false
      )

      add(:quantity, :integer, null: false)

      add(:universe_id, references(:game_universes, on_delete: :nothing, type: :uuid),
        type: :uuid,
        null: false
      )

      add(:team_id, references(:player_teams, on_delete: :nothing, type: :uuid), type: :uuid)

      add(:ship_id, references(:space_ships, on_delete: :nothing, type: :uuid),
        type: :uuid,
        null: false
      )

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists table(:resources_composite_types, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:name, :string, null: false)
      add(:contents, {:array, :uuid})

      add(:universe_id, references(:game_universes, on_delete: :nothing, type: :uuid),
        type: :uuid,
        null: false
      )

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists table(:resources_composite_station_module_instances,
                           primary_key: false
                         ) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:type_id, references(:resources_composite_types, on_delete: :nothing, type: :uuid),
        type: :uuid,
        null: false
      )

      add(:ratios, {:array, :integer}, null: false)
      add(:quantity, :integer, null: false)
      add(:averaged_mass, :float, null: false)

      add(:universe_id, references(:game_universes, on_delete: :nothing, type: :uuid),
        type: :uuid,
        null: false
      )

      add(:team_id, references(:player_teams, on_delete: :nothing, type: :uuid), type: :uuid)

      add(
        :station_module_id,
        references(:space_station_modules, on_delete: :nothing, type: :uuid),
        type: :uuid,
        null: false
      )

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists table(:resources_composite_ship_instances, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:type_id, references(:resources_composite_types, on_delete: :nothing, type: :uuid),
        type: :uuid,
        null: false
      )

      add(:ratios, {:array, :integer}, null: false)
      add(:quantity, :integer, null: false)
      add(:averaged_mass, :float, null: false)

      add(:universe_id, references(:game_universes, on_delete: :nothing, type: :uuid),
        type: :uuid,
        null: false
      )

      add(:team_id, references(:player_teams, on_delete: :nothing, type: :uuid), type: :uuid)

      add(:ship_id, references(:space_ships, on_delete: :nothing, type: :uuid),
        type: :uuid,
        null: false
      )

      timestamps(type: :utc_datetime_usec)
    end
  end
end
