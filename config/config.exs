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

# Configures Guardian
# NOTE: The `secret_key` is a default value for dev / testing environments.  It
#       MUST be overridden in prod.secret.exs before depolying the app to a
#       production environment.
config :ferry, Ferry.Auth.Guardian,
  issuer: "ferry",
  secret_key: "super-secret"

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

# Configures the tracer
config :ferry, FerryWeb.Tracer,
  service: :ferry,
  adapter: SpandexDatadog.Adapter,
  env: {:system, "ENV"}

config :spandex_phoenix,
  tracer: FerryWeb.Tracer

config :spandex_ecto, SpandexEcto.EctoLogger,
  service: :ferry,
  tracer: FerryWeb.Tracer

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

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
