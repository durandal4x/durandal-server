defmodule Durandal.Types.StationModuleType do
  @moduledoc """
  # StationModuleType
  Description here

  ### Attributes
  * `:name` - field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "station_module_types" do
    field(:name, :string)
    belongs_to(:universe, Durandal.Game.Universe, type: Ecto.UUID)

    field(:build_time, :integer)
    field(:max_health, :integer)
    field(:damage, :integer, default: 0)

    timestamps(type: :utc_datetime_usec)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         name: String.t()
  #         universe_id: Durandal.Game.Universe.id(),
  #         build_time: integer(),
  #         max_health: integer(),
  #         damage: integer(),
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(name universe_id build_time max_health)a
  @optional_fields ~w(damage)a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
