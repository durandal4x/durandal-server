defmodule Durandal.Repo.Migrations.CreateSpaceShipsTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:space_ships, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:name, :string)
      add(:team_id, references(:player_teams, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:type_id, references(:ship_types, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:system_id, references(:space_systems, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:position, {:array, :integer})
      add(:velocity, {:array, :integer})

      add(:orbiting_id, references(:space_system_objects, on_delete: :nothing, type: :uuid),
        type: :uuid
      )

      add(:orbit_distance, :integer)
      add(:orbit_clockwise, :boolean)
      add(:orbit_period, :integer)
      add(:build_progress, :integer)
      add(:health, :integer)

      timestamps(type: :utc_datetime_usec)
    end
  end
end
