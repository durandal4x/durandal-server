defmodule Durandal.Blog.Upload do
  @moduledoc false
  use DurandalWeb, :schema

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "blog_poll_responses" do
    belongs_to :uploader, Durandal.Account.User, type: Ecto.UUID

    field :extension, :string
    field :file_size, :integer
    field :contents, :string

    timestamps(type: :utc_datetime)
  end

  @required_fields ~w(uploader_id extension file_size contents)a
  @optional_fields ~w()a

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
