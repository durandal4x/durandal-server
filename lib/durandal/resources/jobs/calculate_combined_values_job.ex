defmodule Durandal.Resources.CalculateCombinedValuesJob do
  @moduledoc """
  Calculates the combined values (mass and volume) for all instances of composite resources.
  """

  import Ecto.Query, warn: false
  alias Durandal.{Repo, Resources}

  def perform(universe_id: universe_id) do
    ship_query =
      from i in Resources.CompositeShipInstance,
        where: i.universe_id == ^universe_id,
        preload: [:type]

    station_query =
      from i in Resources.CompositeStationModuleInstance,
        where: i.universe_id == ^universe_id,
        preload: [:type]

    types =
      Resources.list_resources_simple_types(where: [universe_id: universe_id])
      |> Map.new(fn t ->
        {t.id, t}
      end)

    do_perform(types, ship_query, station_query)
  end

  defp do_perform(types, ship_query, station_query) do
    ship_updates =
      Repo.all(ship_query)
      |> Enum.map(fn instance ->
        averaged_mass =
          Enum.zip(instance.type.contents, instance.ratios)
          |> Enum.reduce(0, fn {type_id, ratio}, acc ->
            extra_mass = types[type_id].mass * ratio
            acc + extra_mass
          end)

        total_ratio = Enum.sum(instance.ratios)
        averaged_mass = averaged_mass / total_ratio

        "UPDATE #{Resources.CompositeShipInstance.__schema__(:source)} SET averaged_mass = #{averaged_mass} WHERE id = '#{instance.id}';"
      end)

    station_updates =
      Repo.all(station_query)
      |> Enum.map(fn instance ->
        averaged_mass =
          Enum.zip(instance.type.contents, instance.ratios)
          |> Enum.reduce(0, fn {type_id, ratio}, acc ->
            extra_mass = types[type_id].mass * ratio
            acc + extra_mass
          end)

        total_ratio = Enum.sum(instance.ratios)
        averaged_mass = averaged_mass / total_ratio

        "UPDATE #{Resources.CompositeStationModuleInstance.__schema__(:source)} SET averaged_mass = #{averaged_mass} WHERE id = '#{instance.id}';"
      end)

    (ship_updates ++ station_updates)
    |> Enum.each(fn query ->
      Ecto.Adapters.SQL.query!(Repo, query, [])
    end)
  end
end
