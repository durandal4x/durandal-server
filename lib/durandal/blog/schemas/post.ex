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

    field :poll_choices, {:array, :string}
    field :poll_result_cache, :map

    has_many :post_tags, Durandal.Blog.PostTag

    many_to_many :tags, Durandal.Blog.Tag,
      join_through: "blog_post_tags",
      join_keys: [post_id: :id, tag_id: :id]

    timestamps(type: :utc_datetime)
  end

  @required_fields ~w(poster_id title contents)a
  @optional_fields ~w(summary view_count poll_choices poll_result_cache)a

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
      |> convert_poll_choices

    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> cast_assoc(:post_tags, tag_ids)
    |> validate_required(@required_fields)
  end

  defp convert_poll_choices(%{poll_choices: pc} = p) when is_list(pc), do: p
  defp convert_poll_choices(%{"poll_choices" => pc} = p) when is_list(pc), do: p

  defp convert_poll_choices(%{poll_choices: pc} = p),
    do: Map.put(p, :poll_choices, String.split(pc, "\n"))

  defp convert_poll_choices(%{"poll_choices" => pc} = p),
    do: Map.put(p, "poll_choices", String.split(pc, "\n"))

  defp convert_poll_choices(p), do: p
end
