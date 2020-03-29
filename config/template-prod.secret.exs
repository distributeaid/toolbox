use Mix.Config

# Prod Secret Config
# ================================================================================
# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).


# Endpoint Secret
# ------------------------------------------------------------
# Endpoint configuration: https://hexdocs.pm/phoenix/Phoenix.Endpoint.html#module-endpoint-configuration
# Generate a new secret: https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Secret.html#content

config :ferry, FerryWeb.Endpoint,
  secret_key_base: "super-secret"


# Database Config
# ------------------------------------------------------------

config :ferry, Ferry.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "toolbox",
  password: "super-secret",
  database: "toolbox_prod",
  pool_size: 15


# Guardian
# ------------------------------------------------------------
# Docs: https://hexdocs.pm/guardian/introduction-overview.html
# Generate a new secret: https://hexdocs.pm/guardian/Mix.Tasks.Guardian.Gen.Secret.html#content

config :ferry, Ferry.Auth.Guardian,
       issuer: "ferry",
       secret_key: "super-secret"


# Twilio Integrations
# ------------------------------------------------------------
# Docs: https://github.com/distributeaid/twilio-integration#overview
# Generate a new secret: Ask Markus (@coderbyheart).

config :ferry, :chat,
  apiKey: "copy-paste",
  endpoint: "send.data.here"
