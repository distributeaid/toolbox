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
  pubsub: [name: Ferry.PubSub,
           adapter: Phoenix.PubSub.PG2]

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

# Configure modules which can be overridden in test.exs by mocks for testing.
config :ferry, :geocoder, Ferry.Locations.Geocoder.Nominatim

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
