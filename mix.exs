defmodule Durandal.MixProject do
  use Mix.Project

  # @source_url "https://github.com/durandal4x/durandal-server"
  @version "0.0.1"

  def project do
    [
      app: :durandal,
      version: @version,
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      description: "Game"
    ]
  end

  def cli() do
    [
      preferred_envs: [
        "test.translations": :test,
        "test.ci": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Durandal.Application, []},
      extra_applications: [:logger, :runtime_tools, :iex]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # These came with Phoenix
      {:phoenix, "~> 1.7"},
      {:phoenix_ecto, "~> 4.6"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.2"},
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      {:phoenix_live_view, "~> 1.0.0"},
      {:floki, ">= 0.34.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:bandit, "~> 1.6"},

      # Extra deps
      {:typedstruct, "~> 0.5.2", runtime: false},
      {:horde, "~> 0.9"},
      {:ecto_psql_extras, "~> 0.7"},
      {:argon2_elixir, "~> 4.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:dart_sass, "~> 0.6"},
      {:fontawesome_icons, "~> 0.0.6"},
      {:cachex, "~> 3.6"},
      {:excoveralls, "~> 0.18.1", only: :test, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:igniter, "~> 0.5", only: [:dev, :test]},
      {:progress_bar, "~> 3.0", only: [:dev, :test]},
      {:db_cluster, "~> 0.0.3"},
      {:oban, "~> 2.19"},
      {:mdex, "~> 0.2"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test.translations": ["test --raise --only translations"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test --raise --exclude translations"],
      "test.reset": ["ecto.drop --quiet", "test.setup"],
      "test.setup": ["ecto.create --quiet", "ecto.migrate --quiet"],
      "assets.setup": ["esbuild.install --if-missing"],
      "assets.build": ["esbuild default"],
      "assets.deploy": [
        "esbuild default --minify",
        "sass dark --no-source-map --style=compressed",
        "sass light --no-source-map --style=compressed",
        "phx.digest"
      ],
      "test.ci": [
        "format --check-formatted",
        "deps.unlock --check-unused",
        "test --raise --exclude translations"
      ]
    ]
  end
end
