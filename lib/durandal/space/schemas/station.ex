defmodule Durandal.Space.Station do
  @moduledoc """
  # Station
  Description here

  ### Attributes
  * `:name` - field description
  * `:team_id` - player_teams field description
  * `:system_id` - space_systems field description
  * `:position` - field description
  * `:velocity` - field description
  * `:orbiting_id` - space_system_objects field description
  * `:orbit_clockwise` - field description
  * `:orbit_period` - field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "space_stations" do
    field(:name, :string)
    belongs_to(:team, Durandal.Player.Team, type: Ecto.UUID)
    belongs_to(:system, Durandal.Space.System, type: Ecto.UUID)
    belongs_to(:universe, Durandal.Game.Universe, type: Ecto.UUID)
    field(:position, {:array, :integer})
    field(:velocity, {:array, :integer})
    belongs_to(:orbiting, Durandal.Space.SystemObject, type: Ecto.UUID)
    field(:orbit_clockwise, :boolean)
    field(:orbit_period, :integer)

    belongs_to(:current_transfer, Durandal.Space.StationTransfer, type: Ecto.UUID)

    has_many(:modules, Durandal.Space.StationModule)
    has_many(:docked_ships, Durandal.Space.Ship, foreign_key: :docked_with_id)

    has_many(:commands, Durandal.Player.Command, foreign_key: :subject_id)

    timestamps(type: :utc_datetime_usec)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         name: String.t(),
  #         team_id: Durandal.Player.Team.id(),
  #         system_id: Durandal.Space.System.id(),
  #         position: [Integer.t()],
  #         velocity: [Integer.t()],
  #         orbiting_id: Durandal.Space.SystemObject.id(),
  #         orbit_clockwise: boolean(),
  #         orbit_period: integer(),
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(name team_id system_id position velocity universe_id)a
  @optional_fields ~w(orbiting_id orbit_clockwise orbit_period current_transfer_id)a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
