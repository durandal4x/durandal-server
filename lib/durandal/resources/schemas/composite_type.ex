defmodule Durandal.Resources.CompositeType do
  @moduledoc """
  # CompositeType
  Description here

  ### Attributes
  * `:name` - field description
  * `:contents` - field description
  * `:universe_id` - game_universes field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "resources_composite_types" do
    field(:name, :string)
    field(:contents, {:array, Ecto.UUID})
    field(:ratios, {:array, :integer})
    field(:averaged_mass, :float)
    belongs_to(:universe, Durandal.Game.Universe, type: Ecto.UUID)

    timestamps(type: :utc_datetime_usec)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         name: String.t(),
  #         contents: [Uuid.t()],
  #         universe_id: Durandal.Game.Universe.id(),
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(name contents ratios averaged_mass universe_id)a
  @optional_fields ~w()a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
