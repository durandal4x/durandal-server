defmodule Durandal.Caches.UserCache do
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
      add_cache(:user_token_identifier_cache, ttl: :timer.minutes(5)),
      add_cache(:one_time_login_code, ttl: :timer.seconds(30)),
      add_cache(:user_by_user_id_cache, ttl: :timer.minutes(5)),
      add_cache(:login_count_ip, ttl: :timer.minutes(5)),
      add_cache(:login_count_user, ttl: :timer.minutes(5))
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
