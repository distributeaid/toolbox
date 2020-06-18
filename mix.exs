defmodule Ferry.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ferry,

      # version: "0.0.28",
      # We got it this far!
      # Who's gonna be the lucky one to bump it up next?!
      # <3 Distribute Aid
      version: "0.0.29",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Ferry.Application, []},
      extra_applications: [:logger, :runtime_tools, :scrivener_ecto, :timex, :absinthe_plug]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # standard deps
      {:phoenix, "~> 1.4.12"},
      {:phoenix_pubsub, "~> 1.1"},
      {:ecto_sql, "~> 3.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.13"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.16"},
      {:plug_cowboy, "~> 2.0"},

      # utilities
      # file uploads
      {:arc_ecto, "~> 0.11"},
      # http
      {:httpoison, "~> 1.4"},
      # json
      {:jason, "~> 1.1"},
      # jwt
      {:joken, "~> 2.2.0"},
      # router redirects
      {:redirect, "~> 0.3.0"},
      # pagination
      {:scrivener_ecto, "~> 2.0"},
      # datetime
      {:timex, "~> 3.0"},

      # file uploads
      {:ex_aws_s3, "~> 2.0"},
      {:poison, "~> 3.1"},
      {:sweet_xml, "~> 0.6"},

      # graphql api
      {:absinthe, "~> 1.4"},
      {:absinthe_error_payload, "~> 1.0"},
      {:absinthe_plug, "~> 1.4"},
      {:dataloader, "~> 1.0.0"},

      # aws
      {:ex_aws, "~> 2.1"},
      {:hackney, "~> 1.9"},

      # authentication
      {:bcrypt_elixir, "~> 1.0"},
      {:comeonin, "~> 4.0"},
      {:guardian, "~> 1.0"},

      # testing
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:ex_machina, "~> 2.3", only: :test},
      {:excoveralls, "~> 0.11", only: :test},
      {:mox, "~> 0.5", only: :test},

      # deployment
      {:distillery, "~> 2.1"},

      # metrics
      {:prometheus, "~> 4.4.1"},
      {:prometheus_ex, "~> 3.0.5"},
      {:prometheus_ecto, "~> 1.4.3"},
      {:prometheus_phoenix, "~> 1.3.0"},
      {:prometheus_plugs, "~> 1.1.5"},
      {:heartcheck, "~> 0.4"},

      # tracing
      {:spandex, "~> 2.4.3"},
      {:spandex_datadog, "~> 0.5.0"},
      {:spandex_ecto, "~> 0.6.1"},
      {:spandex_phoenix, "~> 0.4.1"},

      # dialyzer
      {:dialyxir, "~> 1.0.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
