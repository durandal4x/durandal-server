defmodule Durandal.Game.Universe do
  @moduledoc """
  # Universe
  Description here

  ### Attributes
  * `:name` - field description
  * `:active?` - field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "game_universes" do
    field(:name, :string)
    field(:active?, :boolean)

    timestamps(type: :utc_datetime)

    has_many :teams, Durandal.Player.Team
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         name: String.t(),,
  #         active?: boolean(),
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(name active?)a
  @optional_fields ~w()a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end