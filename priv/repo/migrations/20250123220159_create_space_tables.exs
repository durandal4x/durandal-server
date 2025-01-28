defmodule Durandal.Repo.Migrations.CreateSpaceSystemsTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:space_systems, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:name, :string)

      add(:universe_id, references(:game_universes, on_delete: :nothing, type: :uuid),
        type: :uuid
      )

      timestamps(type: :utc_datetime)
    end
  end
end
