defmodule Durandal.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      {Ecto.Migrator,
       repos: Application.fetch_env!(:durandal, :ecto_repos),
       skip: System.get_env("SKIP_MIGRATIONS") == "true"},

      # Start the Telemetry supervisor
      Durandal.TelemetrySupervisor,
      # Start the Ecto repository
      Durandal.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Durandal.PubSub},
      # Start Finch
      {Finch, name: Durandal.Finch},
      # Start the Endpoint (http/https)
      DurandalWeb.Endpoint,
      # Start a worker by calling: Durandal.Worker.start_link(arg)
      # {Durandal.Worker, arg}

      # Caches
      add_cache(:user_token_identifier_cache, ttl: :timer.minutes(5)),
      add_cache(:durandal_metadata),
      add_cache(:one_time_login_code, ttl: :timer.seconds(30)),
      add_cache(:user_by_user_id_cache, ttl: :timer.minutes(5)),

      # Login rate limiting
      add_cache(:login_count_ip, ttl: :timer.minutes(5)),
      add_cache(:login_count_user, ttl: :timer.minutes(5))
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Durandal.Supervisor]
    start_result = Supervisor.start_link(children, opts)

    Logger.info("Durandal.Supervisor start result: #{Kernel.inspect(start_result)}")

    startup()

    Logger.info("Durandal startup completed")

    start_result
  end

  defp startup() do
    :ok
  end

  @spec add_cache(atom) :: map()
  @spec add_cache(atom, list) :: map()
  defp add_cache(name, opts \\ []) when is_atom(name) do
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

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DurandalWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
