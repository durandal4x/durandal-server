defmodule Durandal.Repo.Migrations.CreateSpaceShipsTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:space_ships, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:name, :string)
      add(:team_id, references(:player_teams, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:type_id, references(:ship_types, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:position, {:array, :integer})

      timestamps(type: :utc_datetime)
    end
  end
end
