defmodule Durandal.Blog.UserPreference do
  @moduledoc false
  use DurandalWeb, :schema

  @primary_key false
  schema "blog_user_preferences" do
    belongs_to :user, Durandal.Account.User, primary_key: true, type: Ecto.UUID

    field :tag_mode, :string

    field :enabled_tags, {:array, Ecto.UUID}, default: []
    field :disabled_tags, {:array, Ecto.UUID}, default: []

    field :enabled_posters, {:array, Ecto.UUID}, default: []
    field :disabled_posters, {:array, Ecto.UUID}, default: []

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(Map.t(), Map.t()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(
      params,
      ~w(user_id tag_mode enabled_tags disabled_tags enabled_posters disabled_posters)a
    )
    |> validate_required(~w(user_id)a)
  end
end
