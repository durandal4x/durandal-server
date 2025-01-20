defmodule Durandal.Context.Object do
  @moduledoc """
  # Object
  Description here

  ### Attributes

  * `:v1` - Value 1
  * `:v2` - Value 2
  """
  use DurandalWeb, :schema

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "object_table" do
    field(:key, :string)
    field(:value, :string)

    timestamps()
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         key: String.t(),
  #         field: String.t(),
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @doc false
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, ~w(key value)a)
    |> validate_required(~w(key value)a)
  end
end
