defmodule Durandal.Repo.Migrations.CreateSettings do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:settings_server_settings, primary_key: false) do
      add(:key, :string, primary_key: true)
      add(:value, :text)

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists table(:settings_user_settings, primary_key: false) do
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid),
        type: :uuid,
        primary_key: true
      )

      add(:key, :string, primary_key: true)
      add(:value, :string)

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists(index(:settings_user_settings, [:user_id]))
  end
end
