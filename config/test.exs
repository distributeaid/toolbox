use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ferry, FerryWeb.Endpoint,
  http: [port: 1314],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :ferry, Ferry.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("POSTGRES_USER") || "toolbox",
  password: System.get_env("POSTGRES_PASSWORD") || "1312",
  database: System.get_env("POSTGRES_DB") || "toolbox_test",
  hostname: System.get_env("POSTGRES_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Reduce the # of password hashing rounds to speed up the test suite.
config :bcrypt_elixir, :log_rounds, 4
