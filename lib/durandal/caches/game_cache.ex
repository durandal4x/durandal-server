defmodule Durandal.Caches.GameCache do
  @moduledoc """
  Cache for user related caches
  """

  use Supervisor
  import Durandal.CacheClusterServer, only: [add_cache: 2]

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      add_cache(:universe_by_universe_id_cache, ttl: :timer.minutes(5)),
      add_cache(:player_team_by_team_id_cache, ttl: :timer.minutes(5)),
      add_cache(:player_team_member_by_team_id_user_id_cache, ttl: :timer.minutes(5)),
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
