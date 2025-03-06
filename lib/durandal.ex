defmodule Durandal do
  @moduledoc """
  Durandal
  """

  @type user_id :: Durandal.Account.User.id()

  @type universe_id :: Durandal.Game.Universe.id()

  @type team_id :: Durandal.Player.Team.id()

  @type system_id :: Durandal.Space.System.id()
  @type system_object_id :: Durandal.Space.SystemObject.id()
  @type station_id :: Durandal.Space.Station.id()
  @type station_module_id :: Durandal.Space.StationModule.id()
  @type ship_id :: Durandal.Space.Ship.id()

  @type station_module_type_id :: Durandal.Types.StationModuleType.id()
  @type system_object_type_id :: Durandal.Types.SystemObjectType.id()
  @type ship_type_id :: Durandal.Types.ShipType.id()

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
  @spec broadcast_on_ok({:ok, any} | {:error, any}, String.t() | function(), atom(), map()) :: :ok
  defdelegate broadcast_on_ok(result, topic, result_key, message), to: PubSubHelper

  @doc false
  @spec subscribe(String.t()) :: :ok
  defdelegate subscribe(topic), to: PubSubHelper

  @doc false
  @spec unsubscribe(String.t()) :: :ok
  defdelegate unsubscribe(topic), to: PubSubHelper

  # Cluster cache delegation
  @spec invalidate_cache(atom, any) :: :ok
  defdelegate invalidate_cache(table, key_or_keys), to: Durandal.CacheClusterServer

  @spec invalidate_cache_on_ok(any, atom) :: any
  defdelegate invalidate_cache_on_ok(value, table), to: Durandal.CacheClusterServer

  @spec invalidate_cache_on_ok(any, atom, atom) :: any
  defdelegate invalidate_cache_on_ok(value, table, id_field), to: Durandal.CacheClusterServer
end
