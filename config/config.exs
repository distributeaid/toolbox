# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ferry,
  ecto_repos: [Ferry.Repo]

# Configures the endpoint
config :ferry, FerryWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "LZq0A0L5e94eTPVfqLXxmWjEG2LN4/RaoBZacm7X4t1a81wbHbj95pXZNU+rzEjH",
  render_errors: [view: FerryWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Ferry.PubSub,
  live_view: [signing_salt: "w5u8sooV1GpBhBDnW/kFF8Hvd3cYnEP6+Alc9BjC1o3mAymHFwJSoiRCjZbFBnS8"]

config :ferry, Ferry.Token,
  signer_alg: "RS256",
  audience: "3wxYeItzvD1fN5tloBikUHED8sQ1BImj",
  issuer: "https://distributeaid.eu.auth0.com/",
  public_key:
    "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tDQpNSUlERHpDQ0FmZWdBd0lCQWdJSkRiTi9BQ2tpZXlXdE1BMEdDU3FHU0liM0RRRUJDd1VBTUNVeEl6QWhCZ05WDQpCQU1UR21ScGMzUnlhV0oxZEdWaGFXUXVaWFV1WVhWMGFEQXVZMjl0TUI0WERUSXdNVEF5TnpJd01EZzBPRm9YDQpEVE0wTURjd05qSXdNRGcwT0Zvd0pURWpNQ0VHQTFVRUF4TWFaR2x6ZEhKcFluVjBaV0ZwWkM1bGRTNWhkWFJvDQpNQzVqYjIwd2dnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUJEd0F3Z2dFS0FvSUJBUURjQmtEVWxEU1gvTEdjDQorN3N4Q1dMVjZ3OTJkNUIwYlFqM1F5L1d3S1dUQlNBL1pDZlFncjRkK0VYdWZVaGhTVlJYSDQvNWdrWHVxT25mDQo5aUNVSEFTOU15T1hMUkxnU0ZVRnljVFI4czBROCtHZXRPekVyNHJZNERyWmE2eDRGVjFCYm1YY29BdThvOElwDQp1cUVGNzJSQXRJcEp5MzhJNzd0dHV3MGhTQmJPSEFaNmxXUGhXU0VpaExSZzNhZ05RUWV6L1BVT3ZkbG5aRE9ZDQp4V25iSUs0WU9yUHNKajRzYTVxdmNrZDZQY09RaUpUMVc5Y3laWE13NGVLclMwTUcwUXZaNjhYa3F6NVJ1aGM1DQpxQmREQmp0cUk0MFhVNTdTYmRqVkVuUU01NWtNRWs2MEttQzgxRTk2UE9IaVk1YmhOZVBLTDlmWEF5cDJGeGl3DQovMVlRL1JRQkFnTUJBQUdqUWpCQU1BOEdBMVVkRXdFQi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZIc0pEVEN2DQpOOWpobnFCR3UyK0RiSU9Oa3NtRE1BNEdBMVVkRHdFQi93UUVBd0lDaERBTkJna3Foa2lHOXcwQkFRc0ZBQU9DDQpBUUVBQUgwNEp4aFVRMXpXT3dXY2pnZjBKb2tRSlNIV3pzWkRhWkgvY241V1E5VGlDNkwzT0tSSytSNnMzaFBxDQpmSE9zUGNKODd3d1JQS053S1B1VjNpY3Q0SXhRamp3TWVKZlJtcFlMY3NIOTJvRC9KTnNPQkxEK3JmamU2cEdzDQpKNDdLbkc0ZHJ2RzYzekhjRnVpZ3ZWMHFpV0RSelF0MWZSdkx6QjdZM2pTSS9MQXBtSWFKZ2RPZFJWMm9LVjU3DQppVmNZdjFRVkdLY2NIdGtMTVVzSHBBNzRGb2YxVlZDcUFqbVA5aTlhOHVkOWgrRUFhTHhJUTlFT09EUUJqdVlvDQovWTI1L2xjU3RUU0V2YWFlNjZPdVBJL0NHUGpmN0FsNWNIelE0U0dkaTdFSU1BSVVjdDZZOFZkQmpJNHM5bEttDQpKbnBGYldLeS80eDllMzRCUUs4dzhmcWFQZz09DQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0t"

# Configures Arq
config :arc,
  storage: Arc.Storage.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure modules which can be overridden in test.exs by mocks for testing.
config :ferry, :geocoder, Ferry.Locations.Geocoder.Nominatim
config :ferry, :aws_client, Ferry.AwsClient

config :ferry, :jwt,
  keyId: "12599b51-11b7-4c45-8f8a-a2bd1a6c5745",
  privateKey: """
  -----BEGIN EC PRIVATE KEY-----
  MHcCAQEEICZqujJqPxmKWeyxq4D7bLqOHDKOEM+6jTJcPCQ9hSryoAoGCCqGSM49
  AwEHoUQDQgAEDCz8s7nGPQyWZY0jkrL5VzKbE9EWLkNwOWoI98nOVU42SYw0ooqX
  IYNPX2oZSKmvkF17xXd+ThXLsi9it8nplg==
  -----END EC PRIVATE KEY-----
  """,
  publicKey: """
  -----BEGIN PUBLIC KEY-----
  MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEDCz8s7nGPQyWZY0jkrL5VzKbE9EW
  LkNwOWoI98nOVU42SYw0ooqXIYNPX2oZSKmvkF17xXd+ThXLsi9it8nplg==
  -----END PUBLIC KEY-----
  """

config :ferry, :chat,
  apiKey: "da2-mex4f66y3rd6pd7zhocoyaallm",
  endpoint: "https://iqvxvl3zzfeuxm622y5fcwpfjq.appsync-api.eu-central-1.amazonaws.com/graphql"

config :prometheus, FerryWeb.PipelineInstrumenter,
  labels: [:status_class, :method, :host, :scheme, :request_path],
  duration_buckets: [
    0,
    10,
    30,
    100,
    300
  ],
  registry: :default,
  duration_unit: :microseconds

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
  region: {:system, "AWS_REGION"}

config :ferry, :graphiql, System.get_env("GRAPHIQL", "enable")
config :ferry, :auth, System.get_env("AUTH", "enable")
config :ferry, :dashboard, System.get_env("DASHBOARD", "disable")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
