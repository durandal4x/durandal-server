defmodule Durandal.Blog.PollResponseQueries do
  @moduledoc false
  use DurandalWeb, :queries
  alias Durandal.Blog.PollResponse

  # Queries
  @spec query_poll_responses(list) :: Ecto.Query.t()
  def query_poll_responses(args) do
    query = from(poll_responses in PollResponse)

    query
    |> do_where(args[:where])
    # |> do_preload(args[:preload])
    |> do_order_by(args[:order_by])
    |> QueryHelper.query_select(args[:select])
    |> QueryHelper.limit_query(args[:limit])
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
  defp _where(query, _, ""), do: query
  defp _where(query, _, nil), do: query

  defp _where(query, :id, id) do
    from poll_responses in query,
      where: poll_responses.id == ^id
  end

  defp _where(query, :user_id, user_id) do
    from poll_responses in query,
      where: poll_responses.user_id in ^List.wrap(user_id)
  end

  defp _where(query, :post_id, post_id) do
    from poll_responses in query,
      where: poll_responses.post_id in ^List.wrap(post_id)
  end

  @spec do_order_by(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
  defp do_order_by(query, nil), do: query

  defp do_order_by(query, params) when is_list(params) do
    params
    |> Enum.reduce(query, fn key, query_acc ->
      _order_by(query_acc, key)
    end)
  end

  defp do_order_by(query, params) when is_bitstring(params), do: do_order_by(query, [params])

  defp _order_by(query, nil), do: query

  defp _order_by(query, "Newest first") do
    from poll_responses in query,
      order_by: [desc: poll_responses.inserted_at]
  end

  defp _order_by(query, "Oldest first") do
    from poll_responses in query,
      order_by: [asc: poll_responses.inserted_at]
  end

  # @spec do_preload(Ecto.Query.t(), List.t() | nil) :: Ecto.Query.t()
  # defp do_preload(query, nil), do: query

  # defp do_preload(query, preloads) do
  #   preloads
  #   |> Enum.reduce(query, fn key, query_acc ->
  #     _preload(query_acc, key)
  #   end)
  # end

  # defp _preload(query, :poll_responseer) do
  #   from poll_responses in query,
  #     left_join: poll_responseers in assoc(poll_responses, :poll_responseer),
  #     preload: [poll_responseer: poll_responseers]
  # end

  # # This just grabs the tags
  # defp _preload(query, :tags) do
  #   from poll_responses in query,
  #     join: tags in assoc(poll_responses, :tags),
  #     preload: [tags: tags]
  # end

  # # This applies filtering on which poll_responses we get based on possession of tags
  # defp _preload(query, {:tags, [], []}) do
  #   from poll_responses in query,
  #     join: tags in assoc(poll_responses, :tags),
  #     preload: [tags: tags]
  # end

  def responses_by_choice(post_id) do
    from poll_responses in PollResponse,
      where: poll_responses.post_id == ^post_id,
      group_by: poll_responses.response,
      select: {poll_responses.response, count(poll_responses.user_id)}
  end
end
