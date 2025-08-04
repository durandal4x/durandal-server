defmodule Durandal.Resources.CalculateCombinedValuesJob do
  @moduledoc """
  Calculates the combined values (just mass right now) for all composite types
  """

  import Ecto.Query, warn: false
  alias Durandal.Resources

  def perform(universe_id: universe_id) do
    simple_types =
      Resources.list_simple_types(where: [universe_id: universe_id])
      |> Map.new(fn t ->
        {t.id, t}
      end)

    Resources.list_composite_types(where: [universe_id: universe_id])
    |> Enum.each(fn ct ->
      averaged_mass =
        Enum.zip(ct.contents, ct.ratios)
        |> Enum.reduce(0, fn {type_id, ratio}, acc ->
          extra_mass = simple_types[type_id].mass * ratio
          acc + extra_mass
        end)

      total_ratio = Enum.sum(ct.ratios)
      averaged_mass = averaged_mass / total_ratio

      Resources.update_composite_type(ct, %{averaged_mass: averaged_mass})
    end)
  end
end
