defmodule Durandal.Resources.CompositeShipInstance do
  @moduledoc """
  # CompositeShipInstance
  Description here

  ### Attributes
  * `:type_id` - resources_composite_types field description
  * `:ratios` - field description
  * `:quantity` - field description
  * `:averaged_mass` - field description
  * `:universe_id` - game_universes field description
  * `:ship_id` - space_ships field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "resources_composite_ship_instances" do
    belongs_to(:type, Durandal.Resources.CompositeType, type: Ecto.UUID)
    field(:ratios, {:array, :integer})
    field(:quantity, :integer)
    field(:averaged_mass, :float)
    belongs_to(:universe, Durandal.Game.Universe, type: Ecto.UUID)
    belongs_to(:ship, Durandal.Space.Ship, type: Ecto.UUID)
    belongs_to(:team, Durandal.Player.Team, type: Ecto.UUID)

    timestamps(type: :utc_datetime_usec)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         type_id: resources_composite_types.id(),
  #         ratios: [Integer.t()],
  #         quantity: integer(),
  #         averaged_mass: float(),
  #         universe_id: Durandal.Game.Universe.id(),
  #         ship_id: Durandal.Space.Ship.id(),
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(type_id ratios quantity averaged_mass universe_id ship_id team_id)a
  @optional_fields ~w()a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
