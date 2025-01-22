defmodule Durandal.Space.Station do
  @moduledoc """
  # Station
  Description here

  ### Attributes
  * `:name` - field description
  * `:team_id` - field description
  * `:position` - field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "space_stations" do
    field(:name, :string)
    belongs_to(:team, Durandal.Player.Team, type: Ecto.UUID)
    field(:position, {:array, :integer})

    timestamps(type: :utc_datetime)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         name: String.t(),
  #         team_id: player_teams.id(),
  #       position: [Integer.t()]
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(name team_id position)a
  @optional_fields ~w()a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
