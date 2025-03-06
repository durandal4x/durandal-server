defmodule Durandal.CacheClusterServer do
  @moduledoc """
  Allows us to track cache invalidation across a cluster.
  """
  use GenServer
  alias Phoenix.PubSub

  @spec invalidate_cache(atom, any) :: :ok
  def invalidate_cache(table, key_or_keys) do
    key_or_keys
    |> List.wrap()
    |> Enum.each(fn key ->
      Cachex.del(table, key)
    end)

    Phoenix.PubSub.broadcast(
      Durandal.PubSub,
      "cache_cluster",
      {:cache_cluster, :delete, Node.self(), table, key_or_keys}
    )
  end

  @spec invalidate_cache_on_ok(any, atom) :: any
  def invalidate_cache_on_ok(v, table), do: invalidate_cache_on_ok(v, table, :id)

  @spec invalidate_cache_on_ok(any, atom, atom) :: any
  def invalidate_cache_on_ok({:ok, value}, table, id_field) do
    id_value = Map.get(value, id_field)

    invalidate_cache(table, id_value)
    {:ok, value}
  end
  def invalidate_cache_on_ok(v, _, _), do: v

  @spec add_cache(atom, list) :: map()
  def add_cache(name, opts \\ []) when is_atom(name) do
    %{
      id: name,
      start:
        {Cachex, :start_link,
         [
           name,
           opts
         ]}
    }
  end

  @spec start_link(list) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  @impl true
  def handle_info({:cache_cluster, :delete, from_node, table, key_or_keys}, state) do
    if from_node != Node.self() do
      key_or_keys
      |> List.wrap()
      |> Enum.each(fn key ->
        Cachex.del(table, key)
      end)
    end

    {:noreply, state}
  end

  @impl true
  @spec init(any) :: {:ok, %{}}
  def init(_) do
    :ok = PubSub.subscribe(Durandal.PubSub, "cache_cluster")
    {:ok, %{}}
  end
end
