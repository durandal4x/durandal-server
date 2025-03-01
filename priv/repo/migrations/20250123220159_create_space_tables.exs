defmodule Durandal.Repo.Migrations.CreateSpaceSystemsTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:space_systems, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:name, :string)

      add(:universe_id, references(:game_universes, on_delete: :nothing, type: :uuid),
        type: :uuid
      )

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists(index(:space_systems, [:universe_id]))

    create_if_not_exists table(:space_system_objects, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:name, :string)

      add(:type_id, references(:system_object_types, on_delete: :nothing, type: :uuid),
        type: :uuid
      )

      add(:universe_id, references(:game_universes, on_delete: :nothing, type: :uuid),
        type: :uuid
      )

      add(:system_id, references(:space_systems, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:position, {:array, :integer})
      add(:velocity, {:array, :integer})

      add(:orbiting_id, references(:space_system_objects, on_delete: :nothing, type: :uuid),
        type: :uuid
      )

      add(:orbit_distance, :integer)
      add(:orbit_clockwise, :boolean)
      add(:orbit_period, :integer)

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists(index(:space_system_objects, [:type_id]))
    create_if_not_exists(index(:space_system_objects, [:system_id]))
    create_if_not_exists(index(:space_system_objects, [:orbiting_id]))
    create_if_not_exists(index(:space_system_objects, [:universe_id]))
  end
end
