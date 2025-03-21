import Config

config :durandal,
  test: true,
  scenario_path: "priv/test_scenarios"

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :durandal, Durandal.Repo,
  username: "durandal_test",
  password: "postgres",
  hostname: "localhost",
  database: "durandal_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10,
  timeout: 300_000

config :db_cluster,
  enabled: false

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :durandal, DurandalWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "mOFrow0rdGspoZT8Bdnv5qSU8N4p8ZawM0OoIYvQ+08BhFA325EKcZxvkjMKXWRq",
  server: false

# In test we don't send emails.
config :durandal, Durandal.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# This makes anything in our tests involving user passwords (creating or logging in) much faster
config :argon2_elixir, t_cost: 1, m_cost: 8
