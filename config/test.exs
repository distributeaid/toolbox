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
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  database: System.get_env("POSTGRES_DB"),
  hostname: System.get_env("DB_HOSTNAME_TEST"),
  pool: Ecto.Adapters.SQL.Sandbox

# Reduce the # of password hashing rounds to speed up the test suite.
config :bcrypt_elixir, log_rounds: 4

# Override modules with mocks for testing.
config :ferry, :geocoder, Ferry.Locations.Geocoder.GeocoderMock

config :ferry, :jwt, 
  keyId: "12599b51-11b7-4c45-8f8a-a2bd1a6c5745",
  privateKey: """
              -----BEGIN EC PRIVATE KEY-----
              MHcCAQEEICZqujJqPxmKWeyxq4D7bLqOHDKOEM+6jTJcPCQ9hSryoAoGCCqGSM49
              AwEHoUQDQgAEDCz8s7nGPQyWZY0jkrL5VzKbE9EWLkNwOWoI98nOVU42SYw0ooqX
              IYNPX2oZSKmvkF17xXd+ThXLsi9it8nplg==
              -----END EC PRIVATE KEY-----
              """,
  publicKey:  """
              -----BEGIN PUBLIC KEY-----
              MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEDCz8s7nGPQyWZY0jkrL5VzKbE9EW
              LkNwOWoI98nOVU42SYw0ooqXIYNPX2oZSKmvkF17xXd+ThXLsi9it8nplg==
              -----END PUBLIC KEY-----
              """

config :ferry, :chat,
  apiKey: "da2-ojgtsxntpnd4loyp67r6nm3lam",
  endpoint: "https://uftb6vmdvze7nbnrfmk2ygipmm.appsync-api.eu-central-1.amazonaws.com/graphql"
