defmodule Durandal.Space.ColonyModule do
  @moduledoc """
  # ColonyModule
  Description here

  ### Attributes
  * `:colony_id` - field description
  * `:type_id` - field description
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "space_colony_modules" do
    belongs_to(:colony, Durandal.Space.Colony, type: Ecto.UUID)
    belongs_to(:type, Durandal.Types.ColonyModuleType, type: Ecto.UUID)

    timestamps(type: :utc_datetime)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         colony_id: colonies.id(),
  #         type_id: ColonyModuleType.id()
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(colony_id type_id)a
  @optional_fields ~w()a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
