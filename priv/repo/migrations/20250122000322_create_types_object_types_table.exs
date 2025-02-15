defmodule Durandal.Repo.Migrations.CreateTypesTables do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:system_object_types, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:name, :string)

      add(:universe_id, references(:game_universes, on_delete: :nothing, type: :uuid),
        type: :uuid
      )

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists(index(:system_object_types, [:universe_id]))

    create_if_not_exists table(:station_module_types, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:name, :string)

      add(:build_time, :integer)
      add(:max_health, :integer)
      add(:damage, :integer)

      add(:universe_id, references(:game_universes, on_delete: :nothing, type: :uuid),
        type: :uuid
      )

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists(index(:station_module_types, [:universe_id]))

    create_if_not_exists table(:ship_types, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:name, :string)

      add(:acceleration, :integer)
      add(:build_time, :integer)
      add(:max_health, :integer)
      add(:damage, :integer)

      add(:universe_id, references(:game_universes, on_delete: :nothing, type: :uuid),
        type: :uuid
      )

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists(index(:ship_types, [:universe_id]))
  end
end
