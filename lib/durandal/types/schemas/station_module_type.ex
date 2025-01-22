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

    timestamps(type: :utc_datetime)
  end

  @type id :: Ecto.UUID.t()

  # @type t :: %__MODULE__{
  #         id: id(),
  #         name: String.t()
  #         inserted_at: DateTime.t(),
  #         updated_at: DateTime.t()
  #       }

  @required_fields ~w(name)a
  @optional_fields ~w()a

  @doc false
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
