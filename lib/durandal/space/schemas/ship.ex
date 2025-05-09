defmodule Durandal.Space.Ship do
  @moduledoc """
  # Ship
  Description here

  ### Attributes
  * `:name` - field description
  * `:team_id` - player_teams field description
  * `:type_id` - ship_types field description
  * `:system_id` - space_systems field description
  * `:position` - field description
  * `:velocity` - field description
  * `:orbiting_id` - space_system_objects field description
  * `:orbit_clockwise` - field description
  * `:orbit_period` - field description
  * `:build_progress` - field description
  * `:health` - field description
  * `:docked_with_id` - space_system_objects field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "space_ships" do
    field(:name, :string)
    belongs_to(:team, Durandal.Player.Team, type: Ecto.UUID)
    belongs_to(:type, Durandal.Types.ShipType, type: Ecto.UUID)
    belongs_to(:system, Durandal.Space.System, type: Ecto.UUID)
    belongs_to(:universe, Durandal.Game.Universe, type: Ecto.UUID)
    field(:position, {:array, :integer})
    field(:velocity, {:array, :integer})

    belongs_to(:orbiting, Durandal.Space.SystemObject, type: Ecto.UUID)
    field(:orbit_clockwise, :boolean)
    field(:orbit_period, :integer)

    field(:build_progress, :integer)
    field(:health, :integer)

    belongs_to(:docked_with, Durandal.Space.Station, type: Ecto.UUID)

    has_many(:commands, Durandal.Player.Command, foreign_key: :subject_id)

    timestamps(type: :utc_datetime_usec)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         name: String.t(),
  #         team_id: Durandal.Player.Team.id(),
  #         type_id: Durandal.Types.ShipType.id(),
  #         system_id: Durandal.Space.System.id(),
  #         position: [Integer.t()],
  #         velocity: [Integer.t()],
  #         orbiting_id: Durandal.Space.SystemObject.id(),
  #         orbit_clockwise: boolean(),
  #         orbit_period: integer(),
  #         build_progress: integer(),
  #         health: integer(),
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #         docked_with_id: Durandal.Space.Station.id(),
  #       }

  @required_fields ~w(name team_id type_id system_id position velocity build_progress health universe_id)a
  @optional_fields ~w(orbiting_id orbit_clockwise orbit_period docked_with_id)a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
