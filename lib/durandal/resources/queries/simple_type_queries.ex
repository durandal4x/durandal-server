defmodule Durandal.Resources.SimpleTypeQueries do
  @moduledoc false
  use DurandalMacros, :queries
  alias Durandal.Resources.SimpleType
  require Logger

  @spec simple_type_query(Durandal.query_args()) :: Ecto.Query.t()
  def simple_type_query(args) do
    query = from(resources_simple_types in SimpleType)

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
    from resources_simple_types in query,
      where: resources_simple_types.id in ^List.wrap(id)
  end

  def _where(query, :name, name) do
    from resources_simple_types in query,
      where: resources_simple_types.name in ^List.wrap(name)
  end

  def _where(query, :mass, mass) do
    from resources_simple_types in query,
      where: resources_simple_types.mass in ^List.wrap(mass)
  end

  def _where(query, :volume, volume) do
    from resources_simple_types in query,
      where: resources_simple_types.volume in ^List.wrap(volume)
  end

  def _where(query, :has_tags, tags) do
    from(resources_simple_types in query,
      where: ^tags in resources_simple_types.tags
    )
  end

  def _where(query, :not_has_tags, tags) do
    from(resources_simple_types in query,
      where: ^tags not in resources_simple_types.tags
    )
  end

  def _where(query, :universe_id, :not_nil) do
    from resources_simple_types in query,
      where: not is_nil(resources_simple_types.universe_id)
  end

  def _where(query, :universe_id, :is_nil) do
    from resources_simple_types in query,
      where: is_nil(resources_simple_types.universe_id)
  end

  def _where(query, :universe_id, universe_id) do
    from resources_simple_types in query,
      where: resources_simple_types.universe_id in ^List.wrap(universe_id)
  end

  def _where(query, :inserted_after, timestamp) do
    from resources_simple_types in query,
      where: resources_simple_types.inserted_at >= ^timestamp
  end

  def _where(query, :inserted_before, timestamp) do
    from resources_simple_types in query,
      where: resources_simple_types.inserted_at < ^timestamp
  end

  def _where(query, :updated_after, timestamp) do
    from resources_simple_types in query,
      where: resources_simple_types.updated_at >= ^timestamp
  end

  def _where(query, :updated_before, timestamp) do
    from resources_simple_types in query,
      where: resources_simple_types.updated_at < ^timestamp
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

  def _order_by(query, "Name (A-Z)") do
    from(resources_simple_types in query,
      order_by: [asc: resources_simple_types.name]
    )
  end

  def _order_by(query, "Name (Z-A)") do
    from(resources_simple_types in query,
      order_by: [desc: resources_simple_types.name]
    )
  end

  def _order_by(query, "Newest first") do
    from resources_simple_types in query,
      order_by: [desc: resources_simple_types.inserted_at]
  end

  def _order_by(query, "Oldest first") do
    from resources_simple_types in query,
      order_by: [asc: resources_simple_types.inserted_at]
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

  def _preload(query, :universe) do
    from resources_simple_types in query,
      left_join: game_universes in assoc(resources_simple_types, :universe),
      preload: [universe: game_universes]
  end
end
