defmodule Durandal.Space.ColonyQueries do
  @moduledoc false
  use DurandalMacros, :queries
  alias Durandal.Space.Colony
  require Logger

  @spec colony_query(Durandal.query_args()) :: Ecto.Query.t()
  def colony_query(args) do
    query = from(colonies in Colony)

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
    from colonies in query,
      where: colonies.id in ^List.wrap(id)
  end

  def _where(query, :name, name) do
    from colonies in query,
      where: colonies.name in ^List.wrap(name)
  end

  def _where(query, :team_id, team_id) do
    from colonies in query,
      where: colonies.team_id in ^List.wrap(team_id)
  end

  def _where(query, :has_position, position) do
    from(colonies in query,
      where: ^position in colonies.position
    )
  end

  def _where(query, :not_has_position, position) do
    from(colonies in query,
      where: ^position not in colonies.position
    )
  end

  def _where(query, :inserted_after, timestamp) do
    from colonies in query,
      where: colonies.inserted_at >= ^timestamp
  end

  def _where(query, :inserted_before, timestamp) do
    from colonies in query,
      where: colonies.inserted_at < ^timestamp
  end

  def _where(query, :updated_after, timestamp) do
    from colonies in query,
      where: colonies.updated_at >= ^timestamp
  end

  def _where(query, :updated_before, timestamp) do
    from colonies in query,
      where: colonies.updated_at < ^timestamp
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
    from(users in query,
      order_by: [asc: users.name]
    )
  end

  def _order_by(query, "Name (Z-A)") do
    from(users in query,
      order_by: [desc: users.name]
    )
  end

  def _order_by(query, "Newest first") do
    from colonies in query,
      order_by: [desc: colonies.inserted_at]
  end

  def _order_by(query, "Oldest first") do
    from colonies in query,
      order_by: [asc: colonies.inserted_at]
  end

  @spec do_preload(Ecto.Query.t(), List.t() | nil) :: Ecto.Query.t()
  defp do_preload(query, nil), do: query

  defp do_preload(query, _), do: query
  # defp do_preload(query, preloads) do
  #   preloads
  #   |> List.wrap
  #   |> Enum.reduce(query, fn key, query_acc ->
  #     _preload(query_acc, key)
  #   end)
  # end

  # @spec _preload(Ecto.Query.t(), any) :: Ecto.Query.t()
  # def _preload(query, :relation) do
  #   from colony in query,
  #     left_join: relations in assoc(colony, :relation),
  #     preload: [relation: relations]
  # end

  # def _preload(query, {:relation, join_query}) do
  #   from colony in query,
  #     left_join: relations in subquery(join_query),
  #       on: relations.id == query.relation_id,
  #     preload: [relation: relations]
  # end
end
