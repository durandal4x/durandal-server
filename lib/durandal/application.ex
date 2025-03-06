defmodule Durandal.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      Durandal.TelemetrySupervisor,
      # Start the Ecto repository
      Durandal.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:durandal, :ecto_repos),
       skip: System.get_env("SKIP_MIGRATIONS") == "true"},

      # Start the PubSub system
      {Phoenix.PubSub, name: Durandal.PubSub},
      # Start Finch
      {Finch, name: Durandal.Finch},
      # Start the Endpoint (http/https)
      DurandalWeb.Endpoint,
      # Start a worker by calling: Durandal.Worker.start_link(arg)
      # {Durandal.Worker, arg}

      Durandal.System.CacheClusterServer,

      # Caches
      Durandal.Caches.UserSettingCache,
      Durandal.Caches.ServerSettingCache,
      Durandal.Caches.LoginCountCache,
      Durandal.Caches.TypeLookupCache,
      Durandal.Caches.MetadataCache,
      Durandal.Caches.UserCache,
      Durandal.Caches.GameCache,

      # Game
      {DynamicSupervisor, strategy: :one_for_one, name: Durandal.GameSupervisor},
      {Horde.Registry, [keys: :unique, members: :auto, name: Durandal.GameRegistry]},
      {Horde.Registry, [keys: :unique, members: :auto, name: Durandal.UniverseServerRegistry]}
    ]

    # Some stuff we don't want running during tests (unless we specifcially want it)
    non_test_children =
      if Application.get_env(:durandal, :test) do
        []
      else
        [
          {Durandal.Game.WatcherServer, name: Durandal.Game.WatcherServer}
        ]
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Durandal.Supervisor]
    start_result = Supervisor.start_link(children ++ non_test_children, opts)

    Logger.info("Durandal.Supervisor start result: #{Kernel.inspect(start_result)}")

    startup()

    Logger.info("Durandal startup completed")

    start_result
  end

  defp startup() do
    Durandal.System.StartupLib.perform()
    :ok
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DurandalWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
