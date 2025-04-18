defmodule Durandal.Space.ShipTransfer do
  @moduledoc """
  # ShipTransfer
  Description here

  ### Attributes
  * `:origin` - coordinates originating from
  * `:to_station_id` - space_stations field description
  * `:to_system_object_id` - space_system_objects field description
  * `:universe_id` - game_universes field description
  * `:ship_id` - field description
  * `:distance` - field description
  * `:progress` - field description
  * `:status` - field description
  * `:started_tick` - field description
  * `:completed_tick` - field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "space_ship_transfers" do
    belongs_to(:ship, Durandal.Space.Ship, type: Ecto.UUID)

    field(:origin, {:array, :integer})

    belongs_to(:to_station, Durandal.Space.Station, type: Ecto.UUID)
    belongs_to(:to_system_object, Durandal.Space.SystemObject, type: Ecto.UUID)

    belongs_to(:universe, Durandal.Game.Universe, type: Ecto.UUID)
    field(:distance, :integer)
    field(:progress, :integer)
    field(:progress_percentage, :float)
    field(:status, :string)
    field(:started_tick, :integer)
    field(:completed_tick, :integer)

    timestamps(type: :utc_datetime_usec)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         to_station_id: Durandal.Space.Station.id(),
  #         to_system_object_id: Durandal.Space.SystemObject.id(),
  #         universe_id: Durandal.Game.Universe.id(),
  #         ship_id: Ecto.UUID.t(),
  #         distance: integer(),
  #         progress: integer(),
  #         status: String.t(),
  #         started_tick: integer(),
  #         completed_tick: integer(),
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(universe_id ship_id distance progress status started_tick origin)a
  @optional_fields ~w(to_station_id to_system_object_id completed_tick)a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> calculate_progress_percentage
    |> validate_required(@required_fields)
    |> validate_to
  end

  defp calculate_progress_percentage(changeset) do
    progress = fetch_field!(changeset, :progress) || 0
    distance = fetch_field!(changeset, :distance) || 0

    progress_percentage =
      Durandal.Space.TransferLib.calculate_progress_percentage(progress, distance)

    changeset
    |> put_change(:progress_percentage, progress_percentage)
  end

  defp validate_to(changeset) do
    station_id = fetch_field!(changeset, :to_station_id)
    system_object_id = fetch_field!(changeset, :to_system_object_id)

    case {station_id, system_object_id} do
      {nil, nil} ->
        changeset
        |> add_error(:to_station_id, "Need a destination")
        |> add_error(:to_system_object_id, "Need a destination")

      {nil, _} ->
        changeset

      {_, nil} ->
        changeset

      {_, _} ->
        changeset
        |> add_error(:to_station_id, "Can only have one destination")
        |> add_error(:to_system_object_id, "Can only have one destination")
    end
  end
end
