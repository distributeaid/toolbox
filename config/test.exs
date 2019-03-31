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
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASSWORD"),
  database: System.get_env("DB_DATABASE"),
  hostname: System.get_env("DB_HOSTNAME"),
  pool: Ecto.Adapters.SQL.Sandbox

# Reduce the # of password hashing rounds to speed up the test suite.
config :bcrypt_elixir, :log_rounds, 4

# Override modules with mocks for testing.
config :ferry, :geocoder, Ferry.Locations.Geocoder.GeocoderMock
