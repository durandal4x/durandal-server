# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :durandal,
  ecto_repos: [Durandal.Repo],
  scenario_path: "priv/scenarios",
  blog_allow_upload: true,
  blog_upload_path: "zignore/uploads",
  blog_upload_extensions: ~w(.jpg .jpeg .png),
  site_icon: "moon-over-sun",
  generators: [
    timestamp_type: :utc_datetime
  ]

config :durandal, DurandalWeb.Gettext,
  default_locale: "en_gb",
  locales: ~w(en_gb cy_gb)

# Configures the endpoint
config :durandal, DurandalWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: DurandalWeb.ErrorHTML, json: DurandalWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Durandal.PubSub,
  live_view: [signing_salt: "51gUT92P"]

config :db_cluster,
  repo: Durandal.Repo

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :durandal, Durandal.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :dart_sass,
  version: "1.61.0",
  light: [
    args: ~w(scss/light.scss ../priv/static/assets/light.css),
    cd: Path.expand("../assets", __DIR__)
  ],
  dark: [
    args: ~w(scss/dark.scss ../priv/static/assets/dark.css),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:request_id, :user_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
