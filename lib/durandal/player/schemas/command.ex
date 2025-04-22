defmodule Durandal.Player.Command do
  @moduledoc """
  # Command
  Description here

  ### Attributes
  * `:command_type` - field description
  * `:subject_type` - field description
  * `:subject_id` - field description
  * `:ordering` - field description
  * `:contents` - field description
  * `:team_id` - player_teams field description
  * `:user_id` - account_users field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "player_commands" do
    field(:command_type, :string)
    field(:subject_type, :string)
    field(:subject_id, Ecto.UUID)
    field(:ordering, :integer)

    # Contents refers to things the user puts in
    field(:contents, :map, default: %{})

    # Outcome is used to store things from the execution of the command, can serve as a cache
    field(:outcome, :map)

    field(:progress, :integer, default: 0)

    belongs_to(:team, Durandal.Player.Team, type: Ecto.UUID)
    belongs_to(:user, Durandal.Account.User, type: Ecto.UUID)
    belongs_to(:universe, Durandal.Game.Universe, type: Ecto.UUID)

    timestamps(type: :utc_datetime_usec)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         command_type: String.t(),
  #         subject_type: String.t(),
  #         subject_id: Ecto.UUID.t(),
  #         ordering: integer(),
  #         contents: map(),
  #         team_id: Durandal.Player.Team.id(),
  #         user_id: Durandal.Account.User.id(),
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(command_type subject_type subject_id team_id user_id universe_id)a
  @optional_fields ~w(contents ordering progress outcome)a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
