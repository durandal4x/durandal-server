defmodule Durandal.Space.Ship do
  @moduledoc """
  # Ship
  Description here

  ### Attributes
  * `:name` - field description
  * `:team_id` - field description
  * `:type_id` - field description
  * `:position` - field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "space_ships" do
    field(:name, :string)
    belongs_to(:team, Durandal.Player.Team, type: Ecto.UUID)
    belongs_to(:type, Durandal.Types.ShipType, type: Ecto.UUID)
    field(:position, {:array, :integer})

    timestamps(type: :utc_datetime)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         name: String.t(),
  #         team_id: player_teams.id(),
  #         type_id: ship_types.id(),
  #       position: [Integer.t()]
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(name team_id type_id position)a
  @optional_fields ~w()a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
