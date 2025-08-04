defmodule Durandal.Resources.SimpleStationModuleInstance do
  @moduledoc """
  # SimpleStationModuleInstance
  Description here

  ### Attributes
  * `:type_id` - resources_simple_types field description
  * `:quantity` - field description
  * `:universe_id` - game_universes field description
  * `:station_module_id` - space_station_modules field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "resources_simple_station_module_instances" do
    belongs_to(:type, Durandal.Resources.SimpleType, type: Ecto.UUID)
    field(:quantity, :integer)
    belongs_to(:universe, Durandal.Game.Universe, type: Ecto.UUID)
    belongs_to(:station_module, Durandal.Space.StationModule, type: Ecto.UUID)
    belongs_to(:team, Durandal.Player.Team, type: Ecto.UUID)

    timestamps(type: :utc_datetime_usec)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         type_id: resources_simple_types.id(),
  #         quantity: integer(),
  #         universe_id: Durandal.Game.Universe.id(),
  #         station_module_id: Durandal.Space.StationModule.id(),
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(type_id quantity universe_id station_module_id team_id)a
  @optional_fields ~w()a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
