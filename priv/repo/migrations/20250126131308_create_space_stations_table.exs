defmodule Durandal.Repo.Migrations.CreateSpaceStationsTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:space_stations, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:name, :string)
      system_ref
      orbit_ref
      add(:team_id, references(:player_teams, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:position, {:array, :integer})

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists table(:space_station_modules, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:station_id, references(:space_stations, on_delete: :nothing, type: :uuid), type: :uuid)

      add(:type_id, references(:station_module_types, on_delete: :nothing, type: :uuid),
        type: :uuid
      )

      timestamps(type: :utc_datetime)
    end
  end
end
