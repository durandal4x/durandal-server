defmodule Durandal.Player.Command do
  @moduledoc """
  # Command
  Description here

  ### Attributes
  * `:command_type` - field description
  * `:subject_type` - field description
  * `:subject` - field description
  * `:ordering` - field description
  * `:contents` - field description
  * `:team` - field description
  * `:user` - field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "player_commands" do
    field(:command_type, Ecto.UUID)
    field(:subject_type, Ecto.UUID)
    field(:subject, :uuid)
    field(:ordering, :integer)
    field(:contents, :map)
    belongs_to(:team, :player_teams, type: Ecto.UUID)
    belongs_to(:user, :account_users, type: Ecto.UUID)

    timestamps(type: :utc_datetime)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         command_type: String.t(),
  #         subject_type: String.t(),
  #         subject: Ecto.UUID.t(),
  #         ordering: integer(),
  #         contents: map(),
  #         team_id: player_teams.id(),
  #         user_id: account_users.id()
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(command_type subject_type subject ordering contents team user)a
  @optional_fields ~w()a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
