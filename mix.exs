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
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        plt_add_apps: [:mix]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Ferry.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :scrivener_ecto,
        :timex,
        :absinthe_plug,
        :os_mon
      ]
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
      {:phoenix, "~> 1.5.3"},
      {:phoenix_pubsub, "~> 2.0"},
      {:ecto_sql, "~> 3.0", override: true},
      {:phoenix_ecto, "~> 4.1"},
      {:postgrex, ">= 0.15.6"},
      {:phoenix_html, "~> 2.13"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.18"},
      {:plug_cowboy, "~> 2.3"},

      # utilities
      # file uploads
      {:arc_ecto, "~> 0.11.3"},
      # http
      {:httpoison, "~> 1.7"},
      # json
      {:jason, "~> 1.2"},
      # jwt
      {:joken, "~> 2.2.0"},
      # router redirects
      {:redirect, "~> 0.3.0"},
      # pagination
      {:scrivener_ecto, "~> 2.4"},
      # datetime
      {:timex, "~> 3.6"},

      # file uploads
      {:ex_aws_s3, "~> 2.0"},
      {:poison, "~> 4.0", override: true},
      {:sweet_xml, "~> 0.6"},

      # graphql api
      {:absinthe, "~> 1.5"},
      {:absinthe_error_payload, "~> 1.1"},
      {:absinthe_plug, "~> 1.5"},
      {:dataloader, "~> 1.0.0"},

      # aws
      {:ex_aws, "~> 2.1"},
      {:hackney, "~> 1.16"},

      # authentication
      {:bcrypt_elixir, "~> 2.2.0"},
      {:comeonin, "~> 5.3"},
      {:elixir_make, "~> 0.6"},

      # testing
      {:credo, "~> 1.4.0", only: [:dev, :test], runtime: false},
      {:ex_machina, "~> 2.4", only: :test},
      {:excoveralls, "~> 0.13", only: :test},
      {:mox, "~> 0.5", only: :test},

      # deployment
      {:distillery, "~> 2.1"},

      # metrics
      {:prometheus, "~> 4.6"},
      {:prometheus_ex, "~> 3.0.5"},
      {:prometheus_ecto, "~> 1.4.3"},
      {:prometheus_phoenix, "~> 1.3.0"},
      {:prometheus_plugs, "~> 1.1.5"},
      {:heartcheck, "~> 0.4"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:telemetry_metrics_prometheus, "~> 0.6"},
      {:phoenix_live_dashboard, "~> 0.1"},
      {:ecto_psql_extras, "~> 0.2", override: true},

      # dialyzer
      {:dialyxir, "~> 1.0.0", only: [:dev], runtime: false}
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
