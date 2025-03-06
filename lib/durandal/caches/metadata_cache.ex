defmodule Durandal.Caches.MetadataCache do
  @moduledoc """
  Cache for global runtime variables
  """

  use Supervisor
  import Durandal.CacheClusterServer, only: [add_cache: 1]

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      add_cache(:durandal_metadata),
      add_cache(:durandal_system_modules)
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
