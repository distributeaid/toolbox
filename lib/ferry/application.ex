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

    # NOTE: Only for FreeBSD, Linux and OSX (experimental)
    # https://github.com/deadtrickster/prometheus_process_collector
    Prometheus.Registry.register_collector(:prometheus_process_collector)

    :telemetry.attach(
      "prometheus-ecto",
      [:elixir_monitoring_prom, :repo, :query],
      &FerryWeb.RepoInstrumenter.handle_event/4,
      nil
    )

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Ferry.Repo, []),
      # Start the endpoint when the application starts
      supervisor(FerryWeb.Endpoint, []),
      # Start your own worker by calling: Ferry.Worker.start_link(arg1, arg2, arg3)
      # worker(Ferry.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ferry.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FerryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
