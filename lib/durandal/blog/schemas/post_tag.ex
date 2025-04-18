defmodule Durandal.Blog.PostTag do
  @moduledoc false
  use DurandalWeb, :schema

  @primary_key false
  schema "blog_post_tags" do
    belongs_to :post, Durandal.Blog.Post, primary_key: true, type: Ecto.UUID
    belongs_to :tag, Durandal.Blog.Tag, primary_key: true, type: Ecto.UUID
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(Map.t(), Map.t()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(post_id tag_id)a)
    |> validate_required(~w(post_id tag_id)a)
  end

  @spec authorize(atom, Plug.Conn.t(), Map.t()) :: boolean
  def authorize(_action, conn, _params), do: allow?(conn, "Server")
end
