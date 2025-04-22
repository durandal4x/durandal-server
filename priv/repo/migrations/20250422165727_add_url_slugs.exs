defmodule Durandal.Repo.Migrations.AddUrlSlugs do
  use Ecto.Migration

  def change do
    alter table(:blog_posts) do
      add(:url_slug, :string)
    end

    create_if_not_exists(unique_index(:blog_posts, [:url_slug]))
  end
end
