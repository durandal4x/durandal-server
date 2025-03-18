defmodule Durandal.Blog.PollResponse do
  @moduledoc false
  use DurandalWeb, :schema

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "blog_poll_responses" do
    belongs_to :post, Durandal.Blog.Post, type: Ecto.UUID
    belongs_to :user, Durandal.Account.User, type: Ecto.UUID

    field :response, :string

    timestamps(type: :utc_datetime)
  end

  @required_fields ~w(post_id response)a
  @optional_fields ~w(user_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(Map.t(), Map.t()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
