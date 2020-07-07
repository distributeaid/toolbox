defmodule Ferry.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Start all the instrumenters
    FerryWeb.PhoenixInstrumenter.setup()
    FerryWeb.PipelineInstrumenter.setup()
    FerryWeb.RepoInstrumenter.setup()
    FerryWeb.PrometheusExporter.setup()

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      Ferry.Repo,
      FerryWeb.Telemetry,

      # Start the PubSub system
      {Phoenix.PubSub, name: Ferry.PubSub},

      # Start the endpoint when the application starts
      FerryWeb.Endpoint,

      # Start your own worker by calling: Ferry.Worker.start_link(arg1, arg2, arg3)
      worker(
        SpandexDatadog.ApiServer,
        [
          [
            host: System.get_env("DATADOG_HOST") || "localhost",
            port: System.get_env("DATADOG_PORT") || 8126,
            batch_size: System.get_env("SPANDEX_BATCH_SIZE") || 10,
            sync_threshold: System.get_env("SPANDEX_SYNC_THRESHOLD") || 100,
            http: HTTPoison
          ]
        ]
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ferry.Supervisor]
    {:ok, _} = supervisor = Supervisor.start_link(Enum.filter(children, &(!is_nil(&1))), opts)

    Ferry.StartupTasks.migrate()
    supervisor
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FerryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
