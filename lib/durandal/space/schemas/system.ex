defmodule Durandal.Space.System do
  @moduledoc """
  # System
  Description here

  ### Attributes
  * `:name` - field description
  * `:universe_id` - game_universes field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "space_systems" do
    field(:name, :string)
    belongs_to(:universe, Durandal.Game.Universe, type: Ecto.UUID)

    has_many(:system_objects, Durandal.Space.SystemObject)
    has_many(:stations, Durandal.Space.Station)
    has_many(:ships, Durandal.Space.Ship)

    timestamps(type: :utc_datetime_usec)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         name: String.t(),
  #         universe_id: Durandal.Game.Universe.id(),
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(name universe_id)a
  @optional_fields ~w()a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
