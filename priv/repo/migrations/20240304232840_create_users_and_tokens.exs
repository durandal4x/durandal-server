defmodule Durandal.Repo.Migrations.CreateUsersAndTokens do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:account_users, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)
      add(:name, :string)
      add(:email, :string)
      add(:password, :string)

      add(:groups, {:array, :string})
      add(:permissions, {:array, :string})

      timestamps(type: :utc_datetime_usec)
    end

    execute "CREATE INDEX IF NOT EXISTS lower_username ON account_users (LOWER(name))"
    create_if_not_exists(index(:account_users, [:name]))
    create_if_not_exists(unique_index(:account_users, [:email]))

    create table(:account_user_tokens, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)

      add :identifier_code, :string
      add :renewal_code, :string

      add :context, :string
      add :user_agent, :string
      add :ip, :string

      add :expires_at, :utc_datetime
      add :last_used_at, :utc_datetime

      timestamps(type: :utc_datetime_usec)
    end

    create index(:account_user_tokens, [:identifier_code])
    create index(:account_user_tokens, [:user_id])
  end
end
