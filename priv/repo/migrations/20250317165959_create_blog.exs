defmodule Durandal.Repo.Migrations.CreateBlog do
  use Ecto.Migration

  def change do
    create table(:blog_tags, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)
      add(:name, :string)
      add(:colour, :string)
      add(:icon, :string)

      timestamps(type: :utc_datetime_usec)
    end

    create table(:blog_posts, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)
      add(:poster_id, references(:account_users, on_delete: :nothing, type: :uuid))

      add(:title, :string)
      add(:summary, :text)
      add(:contents, :text)

      add(:view_count, :integer)

      timestamps(type: :utc_datetime_usec)
    end

    create table(:blog_post_tags, primary_key: false) do
      add(:post_id, references(:blog_posts, on_delete: :nothing, type: :uuid), primary_key: true)
      add(:tag_id, references(:blog_tags, on_delete: :nothing, type: :uuid), primary_key: true)
    end

    create table(:blog_user_preferences, primary_key: false) do
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid),
        primary_key: true
      )

      add(:tag_mode, :string)

      add(:enabled_tags, {:array, :uuid})
      add(:disabled_tags, {:array, :uuid})

      add(:enabled_posters, {:array, :uuid})
      add(:disabled_posters, {:array, :uuid})

      timestamps(type: :utc_datetime_usec)
    end
  end
end
