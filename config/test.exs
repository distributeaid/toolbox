use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ferry, FerryWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :ferry, Ferry.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "local_dev",
  password: "1312",
  database: "ferry_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
