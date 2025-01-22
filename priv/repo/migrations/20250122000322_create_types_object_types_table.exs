defmodule Durandal.Repo.Migrations.CreateTypesTables do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:system_object_types, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:name, :string)

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists table(:station_module_types, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:name, :string)

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists table(:ship_types, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)

      add(:name, :string)

      timestamps(type: :utc_datetime)
    end
  end
end
