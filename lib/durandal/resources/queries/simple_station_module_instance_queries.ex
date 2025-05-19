defmodule Durandal.Resources.SimpleStationModuleInstanceQueries do
  @moduledoc false
  use DurandalMacros, :queries
  alias Durandal.Resources.SimpleStationModuleInstance
  require Logger

  @spec simple_station_module_instance_query(Durandal.query_args()) :: Ecto.Query.t()
  def simple_station_module_instance_query(args) do
    query = from(resources_simple_station_module_instances in SimpleStationModuleInstance)

    query
    |> do_where(id: args[:id])
    |> do_where(args[:where])
    |> do_where(args[:search])
    |> do_preload(args[:preload])
    |> do_order_by(args[:order_by])
    |> QueryHelper.query_select(args[:select])
    |> QueryHelper.limit_query(args[:limit] || 50)
  end

  @spec do_where(Ecto.Query.t(), list | map | nil) :: Ecto.Query.t()
  defp do_where(query, nil), do: query

  defp do_where(query, params) do
    params
    |> Enum.reduce(query, fn {key, value}, query_acc ->
      _where(query_acc, key, value)
    end)
  end

  @spec _where(Ecto.Query.t(), Atom.t(), any()) :: Ecto.Query.t()
  def _where(query, _, ""), do: query
  def _where(query, _, nil), do: query

  def _where(query, :id, id) do
    from resources_simple_station_module_instances in query,
      where: resources_simple_station_module_instances.id in ^List.wrap(id)
  end

  def _where(query, :type_id, :not_nil) do
    from resources_simple_station_module_instances in query,
      where: not is_nil(resources_simple_station_module_instances.type_id)
  end

  def _where(query, :type_id, :is_nil) do
    from resources_simple_station_module_instances in query,
      where: is_nil(resources_simple_station_module_instances.type_id)
  end

  def _where(query, :type_id, type_id) do
    from resources_simple_station_module_instances in query,
      where: resources_simple_station_module_instances.type_id in ^List.wrap(type_id)
  end

  def _where(query, :quantity, quantity) do
    from resources_simple_station_module_instances in query,
      where: resources_simple_station_module_instances.quantity in ^List.wrap(quantity)
  end

  def _where(query, :universe_id, :not_nil) do
    from resources_simple_station_module_instances in query,
      where: not is_nil(resources_simple_station_module_instances.universe_id)
  end

  def _where(query, :universe_id, :is_nil) do
    from resources_simple_station_module_instances in query,
      where: is_nil(resources_simple_station_module_instances.universe_id)
  end

  def _where(query, :universe_id, universe_id) do
    from resources_simple_station_module_instances in query,
      where: resources_simple_station_module_instances.universe_id in ^List.wrap(universe_id)
  end

  def _where(query, :station_module_id, :not_nil) do
    from resources_simple_station_module_instances in query,
      where: not is_nil(resources_simple_station_module_instances.station_module_id)
  end

  def _where(query, :station_module_id, :is_nil) do
    from resources_simple_station_module_instances in query,
      where: is_nil(resources_simple_station_module_instances.station_module_id)
  end

  def _where(query, :station_module_id, station_module_id) do
    from resources_simple_station_module_instances in query,
      where:
        resources_simple_station_module_instances.station_module_id in ^List.wrap(
          station_module_id
        )
  end

  def _where(query, :inserted_after, timestamp) do
    from resources_simple_station_module_instances in query,
      where: resources_simple_station_module_instances.inserted_at >= ^timestamp
  end

  def _where(query, :inserted_before, timestamp) do
    from resources_simple_station_module_instances in query,
      where: resources_simple_station_module_instances.inserted_at < ^timestamp
  end

  def _where(query, :updated_after, timestamp) do
    from resources_simple_station_module_instances in query,
      where: resources_simple_station_module_instances.updated_at >= ^timestamp
  end

  def _where(query, :updated_before, timestamp) do
    from resources_simple_station_module_instances in query,
      where: resources_simple_station_module_instances.updated_at < ^timestamp
  end

  @spec do_order_by(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
  defp do_order_by(query, nil), do: query

  defp do_order_by(query, params) do
    params
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _order_by(query_acc, key)
    end)
  end

  @spec _order_by(Ecto.Query.t(), any()) :: Ecto.Query.t()

  def _order_by(query, "Newest first") do
    from resources_simple_station_module_instances in query,
      order_by: [desc: resources_simple_station_module_instances.inserted_at]
  end

  def _order_by(query, "Oldest first") do
    from resources_simple_station_module_instances in query,
      order_by: [asc: resources_simple_station_module_instances.inserted_at]
  end

  @spec do_preload(Ecto.Query.t(), List.t() | nil) :: Ecto.Query.t()
  defp do_preload(query, nil), do: query

  defp do_preload(query, preloads) do
    preloads
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _preload(query_acc, key)
    end)
  end

  def _preload(query, :type) do
    from resources_simple_station_module_instances in query,
      left_join:
        resources_simple_types in assoc(resources_simple_station_module_instances, :type),
      preload: [type: resources_simple_types]
  end

  def _preload(query, :universe) do
    from resources_simple_station_module_instances in query,
      left_join: game_universes in assoc(resources_simple_station_module_instances, :universe),
      preload: [universe: game_universes]
  end

  def _preload(query, :station_module) do
    from resources_simple_station_module_instances in query,
      left_join:
        space_station_modules in assoc(resources_simple_station_module_instances, :station_module),
      preload: [station_module: space_station_modules]
  end
end
