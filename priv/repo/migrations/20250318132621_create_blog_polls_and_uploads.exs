defmodule Durandal.Repo.Migrations.CreateBlogPollsAndUploads do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:blog_uploads, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)
      add(:uploader_id, references(:account_users, on_delete: :nothing, type: :uuid))

      add(:extension, :string)
      add(:file_size, :integer)
      add(:contents, :text)

      timestamps(type: :utc_datetime)
    end

    alter table(:blog_posts) do
      add(:poll_choices, {:array, :string})
      add(:poll_result_cache, :jsonb)
    end

    create_if_not_exists table(:blog_poll_responses, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)
      add(:post_id, references(:blog_posts, on_delete: :nothing, type: :uuid), null: false)

      # Can be nulled as we might want to allow anonymous responses
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid))

      add(:response, :string)

      timestamps(type: :utc_datetime)
    end
  end
end
