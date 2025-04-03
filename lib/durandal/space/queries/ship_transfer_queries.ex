defmodule Durandal.Space.ShipTransferQueries do
  @moduledoc false
  use DurandalMacros, :queries
  alias Durandal.Space.ShipTransfer
  require Logger

  @spec ship_transfer_query(Durandal.query_args()) :: Ecto.Query.t()
  def ship_transfer_query(args) do
    query = from(ship_transfers in ShipTransfer)

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
    from ship_transfers in query,
      where: ship_transfers.id in ^List.wrap(id)
  end

  def _where(query, :to_station_id, :not_nil) do
    from ship_transfers in query,
      where: not is_nil(ship_transfers.to_station_id)
  end

  def _where(query, :to_station_id, :is_nil) do
    from ship_transfers in query,
      where: is_nil(ship_transfers.to_station_id)
  end

  def _where(query, :to_station_id, to_station_id) do
    from ship_transfers in query,
      where: ship_transfers.to_station_id in ^List.wrap(to_station_id)
  end

  def _where(query, :to_system_object_id, :not_nil) do
    from ship_transfers in query,
      where: not is_nil(ship_transfers.to_system_object_id)
  end

  def _where(query, :to_system_object_id, :is_nil) do
    from ship_transfers in query,
      where: is_nil(ship_transfers.to_system_object_id)
  end

  def _where(query, :to_system_object_id, to_system_object_id) do
    from ship_transfers in query,
      where: ship_transfers.to_system_object_id in ^List.wrap(to_system_object_id)
  end

  def _where(query, :universe_id, :not_nil) do
    from ship_transfers in query,
      where: not is_nil(ship_transfers.universe_id)
  end

  def _where(query, :universe_id, :is_nil) do
    from ship_transfers in query,
      where: is_nil(ship_transfers.universe_id)
  end

  def _where(query, :universe_id, universe_id) do
    from ship_transfers in query,
      where: ship_transfers.universe_id in ^List.wrap(universe_id)
  end

  def _where(query, :ship_id, ship_id) do
    from ship_transfers in query,
      where: ship_transfers.ship_id in ^List.wrap(ship_id)
  end

  def _where(query, :distance, distance) do
    from ship_transfers in query,
      where: ship_transfers.distance in ^List.wrap(distance)
  end

  def _where(query, :progress, progress) do
    from ship_transfers in query,
      where: ship_transfers.progress in ^List.wrap(progress)
  end

  def _where(query, :status, status) do
    from ship_transfers in query,
      where: ship_transfers.status in ^List.wrap(status)
  end

  def _where(query, :started_tick, started_tick) do
    from ship_transfers in query,
      where: ship_transfers.started_tick in ^List.wrap(started_tick)
  end

  def _where(query, :completed_tick, completed_tick) do
    from ship_transfers in query,
      where: ship_transfers.completed_tick in ^List.wrap(completed_tick)
  end

  def _where(query, :inserted_after, timestamp) do
    from ship_transfers in query,
      where: ship_transfers.inserted_at >= ^timestamp
  end

  def _where(query, :inserted_before, timestamp) do
    from ship_transfers in query,
      where: ship_transfers.inserted_at < ^timestamp
  end

  def _where(query, :updated_after, timestamp) do
    from ship_transfers in query,
      where: ship_transfers.updated_at >= ^timestamp
  end

  def _where(query, :updated_before, timestamp) do
    from ship_transfers in query,
      where: ship_transfers.updated_at < ^timestamp
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
    from ship_transfers in query,
      order_by: [desc: ship_transfers.inserted_at]
  end

  def _order_by(query, "Oldest first") do
    from ship_transfers in query,
      order_by: [asc: ship_transfers.inserted_at]
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

  def _preload(query, :to_station) do
    from ship_transfers in query,
      left_join: space_stations in assoc(ship_transfers, :to_station),
      preload: [to_station: space_stations]
  end

  def _preload(query, :to_system_object) do
    from ship_transfers in query,
      left_join: space_system_objects in assoc(ship_transfers, :to_system_object),
      preload: [to_system_object: space_system_objects]
  end

  def _preload(query, :universe) do
    from ship_transfers in query,
      left_join: game_universes in assoc(ship_transfers, :universe),
      preload: [universe: game_universes]
  end
end
