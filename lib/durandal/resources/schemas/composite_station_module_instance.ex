defmodule Durandal.Resources.CompositeStationModuleInstance do
  @moduledoc """
  # CompositeStationModuleInstance
  Description here

  ### Attributes
  * `:type_id` - resources_composite_types field description
  * `:ratios` - field description
  * `:quantity` - field description
  * `:combined_mass` - field description
  * `:combined_volume` - field description
  * `:universe_id` - game_universes field description
  * `:station_module_id` - space_station_modules field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "resources_composite_station_module_instances" do
    belongs_to(:type, Durandal.Resources.CompositeType, type: Ecto.UUID)
    field(:ratios, {:array, :integer})
    field(:quantity, :integer)
    field(:combined_mass, :integer)
    field(:combined_volume, :integer)
    belongs_to(:universe, Durandal.Game.Universe, type: Ecto.UUID)
    belongs_to(:station_module, Durandal.Space.StationModule, type: Ecto.UUID)
    belongs_to(:team, Durandal.Player.Team, type: Ecto.UUID)

    timestamps(type: :utc_datetime_usec)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         type_id: resources_composite_types.id(),
  #         ratios: [Integer.t()],
  #         quantity: integer(),
  #         combined_mass: integer(),
  #         combined_volume: integer(),
  #         universe_id: Durandal.Game.Universe.id(),
  #         station_module_id: Durandal.Space.StationModule.id(),
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(type_id ratios quantity combined_mass combined_volume universe_id station_module_id team_id)a
  @optional_fields ~w()a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
