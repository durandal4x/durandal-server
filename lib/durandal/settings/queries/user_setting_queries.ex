defmodule Durandal.Settings.UserSettingQueries do
  @moduledoc false
  use DurandalMacros, :queries
  alias Durandal.Settings.UserSetting
  require Logger

  @spec user_setting_query(Durandal.query_args()) :: Ecto.Query.t()
  def user_setting_query(args) do
    query = from(user_settings in UserSetting)

    query
    |> do_where(key: args[:key])
    |> do_where(args[:where])
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

  @spec _where(Ecto.Query.t(), atom, any()) :: Ecto.Query.t()
  def _where(query, _, ""), do: query
  def _where(query, _, nil), do: query

  def _where(query, :key, key_list) when is_list(key_list) do
    from(user_settings in query,
      where: user_settings.key in ^key_list
    )
  end

  def _where(query, :key, key) do
    from(user_settings in query,
      where: user_settings.key == ^key
    )
  end

  def _where(query, :user_id, user_id_list) when is_list(user_id_list) do
    from(user_settings in query,
      where: user_settings.user_id in ^user_id_list
    )
  end

  def _where(query, :user_id, user_id) do
    from(user_settings in query,
      where: user_settings.user_id == ^user_id
    )
  end

  def _where(query, :value, value_list) when is_list(value_list) do
    from(user_settings in query,
      where: user_settings.value in ^value_list
    )
  end

  def _where(query, :value, value) do
    from(user_settings in query,
      where: user_settings.value == ^value
    )
  end

  def _where(query, :inserted_after, timestamp) do
    from(user_settings in query,
      where: user_settings.inserted_at >= ^timestamp
    )
  end

  def _where(query, :inserted_before, timestamp) do
    from(user_settings in query,
      where: user_settings.inserted_at < ^timestamp
    )
  end

  def _where(query, :updated_after, timestamp) do
    from(user_settings in query,
      where: user_settings.updated_at >= ^timestamp
    )
  end

  def _where(query, :updated_before, timestamp) do
    from(user_settings in query,
      where: user_settings.updated_at < ^timestamp
    )
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
    from(user_settings in query,
      order_by: [desc: user_settings.inserted_at]
    )
  end

  def _order_by(query, "Oldest first") do
    from(user_settings in query,
      order_by: [asc: user_settings.inserted_at]
    )
  end

  @spec do_preload(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
  defp do_preload(query, nil), do: query

  defp do_preload(query, _), do: query
  # defp do_preload(query, preloads) do
  #   preloads
  #   |> List.wrap
  #   |> Enum.reduce(query, fn key, query_acc ->
  #     _preload(query_acc, key)
  #   end)
  # end

  # def _preload(query, :relation) do
  #   from user_setting in query,
  #     left_join: relations in assoc(user_setting, :relation),
  #     preload: [relation: relations]
  # end
end
