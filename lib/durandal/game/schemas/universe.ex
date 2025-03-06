defmodule Durandal.Game.Universe do
  @moduledoc """
  # Universe
  Description here

  ### Attributes
  * `:name` - field description
  * `:active?` - field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "game_universes" do
    field(:name, :string)
    field(:active?, :boolean, default: true)

    has_many(:teams, Durandal.Player.Team)
    has_many(:systems, Durandal.Space.System)

    field(:last_tick, :utc_datetime_usec)
    field(:next_tick, :utc_datetime_usec)
    field(:tick_schedule, :string)
    field(:tick_seconds, :integer)

    field(:scenario, :string, virtual: true)

    timestamps(type: :utc_datetime_usec)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         name: String.t(),,
  #         active?: boolean(),
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(name)a
  @optional_fields ~w(active? scenario last_tick next_tick tick_schedule tick_seconds)a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    changeset =
      struct
      |> cast(attrs, @required_fields ++ @optional_fields)
      |> validate_required(@required_fields)

    tick_seconds =
      changeset
      |> Ecto.Changeset.get_field(:tick_schedule)
      |> parse_schedule_string()

    next_tick =
      calculate_next_tick_schedule(Ecto.Changeset.get_field(changeset, :last_tick), tick_seconds)

    changeset
    |> put_change(:tick_seconds, tick_seconds)
    |> put_change(:next_tick, next_tick)
  end

  @spec parse_schedule_string(nil | String.t()) :: nil | integer()
  def parse_schedule_string(nil), do: nil

  def parse_schedule_string(raw_string) do
    formatted_string = String.downcase(raw_string)

    hours =
      case Regex.run(~r/(\d+) hours?/, formatted_string) do
        [_, hours] -> String.to_integer(hours)
        nil -> 0
      end

    minutes =
      case Regex.run(~r/(\d+) minutes?/, formatted_string) do
        [_, minutes] -> String.to_integer(minutes)
        nil -> 0
      end

    seconds =
      case Regex.run(~r/(\d+) seconds?/, formatted_string) do
        [_, seconds] -> String.to_integer(seconds)
        nil -> 0
      end

    hours * 3600 + minutes * 60 + seconds
  end

  @spec calculate_next_tick_schedule(nil | DateTime.t(), integer()) :: DateTime.t()
  def calculate_next_tick_schedule(nil, _), do: DateTime.utc_now()
  def calculate_next_tick_schedule(_, nil), do: nil

  def calculate_next_tick_schedule(last_tick, tick_interval_seconds) do
    DateTime.shift(last_tick, second: tick_interval_seconds)
  end
end
