defmodule Durandal.Space.StationModule do
  @moduledoc """
  # StationModule
  Description here

  ### Attributes
  * `:station_id` - field description
  * `:type_id` - field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "space_station_modules" do
    belongs_to(:station, Durandal.Space.Station, type: Ecto.UUID)
    belongs_to(:type, Durandal.Types.StationModuleType, type: Ecto.UUID)

    timestamps(type: :utc_datetime)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         station_id: space_stations.id(),
  #         type_id: station_module_types.id()
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(station_id type_id)a
  @optional_fields ~w()a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
