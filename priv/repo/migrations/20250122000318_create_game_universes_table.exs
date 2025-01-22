defmodule Durandal.Repo.Migrations.CreateGameUniversesTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:game_universes, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:name, :string)
      add(:active?, :boolean)

      timestamps(type: :utc_datetime_usec)
    end
  end
end
