defmodule Durandal do
  @moduledoc """
  Durandal
  """

  @type user_id :: Durandal.Account.User.id()

  @type query_args ::
          keyword(
            id: non_neg_integer() | nil,
            where: list(),
            preload: list(),
            order_by: list(),
            offset: non_neg_integer() | nil,
            limit: non_neg_integer() | nil
          )

  @spec uuid() :: String.t()
  def uuid() do
    Ecto.UUID.generate()
  end

  # PubSub delegation
  alias Durandal.Helpers.PubSubHelper

  @doc false
  @spec broadcast(String.t(), map()) :: :ok
  defdelegate broadcast(topic, message), to: PubSubHelper

  @doc false
  @spec subscribe(String.t()) :: :ok
  defdelegate subscribe(topic), to: PubSubHelper

  @doc false
  @spec unsubscribe(String.t()) :: :ok
  defdelegate unsubscribe(topic), to: PubSubHelper

  # Cluster cache delegation
  @spec invalidate_cache(atom, any) :: :ok
  defdelegate invalidate_cache(table, key_or_keys), to: Durandal.CacheClusterServer
end
