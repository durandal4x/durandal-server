defmodule Durandal.Space.SystemObject do
  @moduledoc """
  # SystemObject
  Description here

  ### Attributes
  * `:name` - field description
  * `:type_id` - system_object_types field description
  * `:system_id` - space_systems field description
  * `:position` - field description
  * `:velocity` - field description
  * `:orbiting_id` - space_system_objects field description
  * `:orbit_distance` - field description
  * `:orbit_clockwise` - field description
  * `:orbit_period` - field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "space_system_objects" do
    field(:name, :string)
    belongs_to(:type, Durandal.Types.SystemObjectType, type: Ecto.UUID)
    belongs_to(:system, Durandal.Space.System, type: Ecto.UUID)
    belongs_to(:universe, Durandal.Game.Universe, type: Ecto.UUID)
    field(:position, {:array, :integer})
    field(:velocity, {:array, :integer})

    belongs_to(:orbiting, Durandal.Space.SystemObject, type: Ecto.UUID)
    field(:orbit_distance, :integer)
    field(:orbit_clockwise, :boolean)
    field(:orbit_period, :integer)

    timestamps(type: :utc_datetime_usec)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         name: String.t(),
  #         type_id: Durandal.Types.SystemObjectType.id(),
  #         system_id: Durandal.Space.System.id(),
  #         position: [Integer.t()],
  #         velocity: [Integer.t()],
  #         orbiting_id: Durandal.Space.SystemObject.id(),
  #         orbit_distance: integer(),
  #         orbit_clockwise: boolean(),
  #         orbit_period: integer(),
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(name type_id system_id universe_id position velocity)a
  @optional_fields ~w(orbiting_id orbit_distance orbit_clockwise orbit_period)a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
