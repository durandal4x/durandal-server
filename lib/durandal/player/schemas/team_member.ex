defmodule Durandal.Player.TeamMember do
  @moduledoc """
  # TeamMember
  Description here

  ### Attributes
  * `:roles` - field description
  * `:team_id` - field description
  * `:user_id` - field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "player_team_members" do
    field(:roles, {:array, :string})
    belongs_to(:team, Durandal.Player.Team, type: Ecto.UUID)
    belongs_to(:user, Durandal.Account.User, type: Ecto.UUID)

    timestamps(type: :utc_datetime)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #       roles: [String.t()],
  #         team_id: player_teams.id(),
  #         user_id: account_users.id()
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(roles team_id user_id)a
  @optional_fields ~w()a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
