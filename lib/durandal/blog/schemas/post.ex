defmodule Durandal.Blog.Post do
  @moduledoc false
  use DurandalWeb, :schema

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "blog_posts" do
    belongs_to :poster, Durandal.Account.User, type: Ecto.UUID

    field :title, :string
    field :summary, :string
    field :contents, :string
    field :view_count, :integer, default: 0

    has_many :post_tags, Durandal.Blog.PostTag

    many_to_many :tags, Durandal.Blog.Tag,
      join_through: "blog_post_tags",
      join_keys: [post_id: :id, tag_id: :id]

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(Map.t(), Map.t()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    tag_ids =
      params["tags"] ||
        []
        |> Enum.map(fn id -> id end)

    params =
      params
      |> trim_strings(~w(title summary contents)a)

    struct
    |> cast(
      params,
      ~w(poster_id title summary contents view_count)a
    )
    |> cast_assoc(:post_tags, tag_ids)
    |> validate_required(~w(poster_id title contents)a)
  end
end
