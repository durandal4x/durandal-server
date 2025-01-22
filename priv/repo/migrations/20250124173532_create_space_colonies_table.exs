defmodule Durandal.Repo.Migrations.CreateSpaceColoniesTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:space_colonies, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:name, :string)
      system_object_ref
      add(:team_id, references(:player_teams, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:position, {:array, :integer})

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists table(:space_colony_modules, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:colony_id, references(:space_colonies, on_delete: :nothing, type: :uuid), type: :uuid)

      add(:type_id, references(:colony_module_types, on_delete: :nothing, type: :uuid),
        type: :uuid
      )

      timestamps(type: :utc_datetime)
    end
  end
end
