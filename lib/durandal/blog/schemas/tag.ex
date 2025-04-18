defmodule Durandal.Blog.Tag do
  @moduledoc false
  use DurandalWeb, :schema

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "blog_tags" do
    field :name, :string
    field :colour, :string
    field :icon, :string

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(Map.t(), Map.t()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(name colour icon)a)
    |> validate_required(~w(name colour icon)a)
  end

  @spec authorize(atom, Plug.Conn.t(), Map.t()) :: boolean
  def authorize(_action, conn, _params), do: allow?(conn, "Server")
end
