defmodule Durandal.Blog.PollResponseLib do
  @moduledoc false
  use DurandalMacros, :library
  alias Durandal.Blog.{PollResponse, PollResponseQueries}
  alias Phoenix.PubSub

  @doc """
  Returns the list of poll_responses.

  ## Examples

      iex> list_poll_responses()
      [%PollResponse{}, ...]

  """
  @spec list_poll_responses(list) :: [PollResponse]
  def list_poll_responses(args \\ []) do
    args
    |> PollResponseQueries.query_poll_responses()
    |> Repo.all()
  end

  @doc """
  Returns the list of poll_responses.

  ## Examples

      iex> list_poll_responses()
      [%PollResponse{}, ...]

  """
  @spec list_poll_responses_using_preferences(UserPreference.t() | nil, list) :: [PollResponse]
  def list_poll_responses_using_preferences(up), do: list_poll_responses_using_preferences(up, [])

  def list_poll_responses_using_preferences(nil, args) do
    list_poll_responses(args)
  end

  def list_poll_responses_using_preferences(user_preference, args) do
    extra_where = [
      enabled_tags: user_preference.enabled_tags,
      disabled_tags: user_preference.disabled_tags

      # poll_responseer_id_in: [],
      # poll_responseer_id_not_in: []
    ]

    (args ++ [where: extra_where])
    |> PollResponseQueries.query_poll_responses()
    |> Repo.all()
  end

  @doc """
  Gets a single poll_response.

  Raises `Ecto.NoResultsError` if the PollResponse does not exist.

  ## Examples

      iex> get_poll_response!(123)
      %PollResponse{}

      iex> get_poll_response!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_poll_response!(non_neg_integer()) :: PollResponse.t()
  def get_poll_response!(poll_response_id) do
    [id: poll_response_id]
    |> PollResponseQueries.query_poll_responses()
    |> Repo.one!()
  end

  @spec get_poll_response!(non_neg_integer(), list) :: PollResponse.t()
  def get_poll_response!(poll_response_id, args) do
    ([id: poll_response_id] ++ args)
    |> PollResponseQueries.query_poll_responses()
    |> Repo.one!()
  end

  @spec get_poll_response(Durandal.user_id(), Durandal.Blog.Post.id()) :: PollResponse.t() | nil
  def get_poll_response(user_id, post_id) do
    PollResponseQueries.query_poll_responses(
      where: [
        user_id: user_id,
        post_id: post_id
      ],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Creates a poll_response.

  ## Examples

      iex> create_poll_response(%{field: value})
      {:ok, %PollResponse{}}

      iex> create_poll_response(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_poll_response(attrs \\ %{}) do
    %PollResponse{}
    |> PollResponse.changeset(attrs)
    |> Repo.insert()
    |> broadcast_create_poll_response
  end

  defp broadcast_create_poll_response({:ok, %PollResponse{} = poll_response}) do
    spawn(fn ->
      # We sleep this because sometimes the message is seen fast enough the database doesn't
      # show as having the new data (row lock maybe?)
      :timer.sleep(1000)

      PubSub.broadcast(
        Durandal.PubSub,
        "blog_poll_responses",
        %{
          channel: "blog_poll_responses",
          event: :poll_response_created,
          poll_response: poll_response
        }
      )
    end)

    {:ok, poll_response}
  end

  defp broadcast_create_poll_response(value), do: value

  @doc """
  Updates a poll_response.

  ## Examples

      iex> update_poll_response(poll_response, %{field: new_value})
      {:ok, %PollResponse{}}

      iex> update_poll_response(poll_response, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_poll_response(%PollResponse{} = poll_response, attrs) do
    poll_response
    |> PollResponse.changeset(attrs)
    |> Repo.update()
    |> broadcast_update_poll_response
  end

  defp broadcast_update_poll_response({:ok, %PollResponse{} = poll_response}) do
    spawn(fn ->
      # We sleep this because sometimes the message is seen fast enough the database doesn't
      # show as having the new data (row lock maybe?)
      :timer.sleep(1000)

      PubSub.broadcast(
        Durandal.PubSub,
        "blog_poll_responses",
        %{
          channel: "blog_poll_responses",
          event: :poll_response_updated,
          poll_response: poll_response
        }
      )
    end)

    {:ok, poll_response}
  end

  defp broadcast_update_poll_response(value), do: value

  @doc """
  Deletes a poll_response.

  ## Examples

      iex> delete_poll_response(poll_response)
      {:ok, %PollResponse{}}

      iex> delete_poll_response(poll_response)
      {:error, %Ecto.Changeset{}}

  """
  def delete_poll_response(%PollResponse{} = poll_response) do
    query = "DELETE FROM blog_poll_response_tags WHERE poll_response_id = $1;"
    {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [Ecto.UUID.dump!(poll_response.id)])

    Repo.delete(poll_response)
    |> broadcast_delete_poll_response
  end

  defp broadcast_delete_poll_response({:ok, %PollResponse{} = poll_response}) do
    PubSub.broadcast(
      Durandal.PubSub,
      "blog_poll_responses",
      %{
        channel: "blog_poll_responses",
        event: :poll_response_deleted,
        poll_response: poll_response
      }
    )

    {:ok, poll_response}
  end

  defp broadcast_delete_poll_response(value), do: value

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking poll_response changes.

  ## Examples

      iex> change_poll_response(poll_response)
      %Ecto.Changeset{data: %PollResponse{}}

  """
  def change_poll_response(%PollResponse{} = poll_response, attrs \\ %{}) do
    PollResponse.changeset(poll_response, attrs)
  end

  @spec increment_poll_response_view_count(non_neg_integer()) :: Ecto.Changeset
  def increment_poll_response_view_count(poll_response_id) do
    query = "UPDATE blog_poll_responses SET view_count = view_count + 1 WHERE id = $1;"
    {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [Ecto.UUID.dump!(poll_response_id)])
  end
end
