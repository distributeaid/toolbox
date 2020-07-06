defmodule FerryWeb.PhoenixInstrumenter do
  @moduledoc "Prometheus instrmenter for Phoenix"

  use Prometheus.PhoenixInstrumenter
end

defmodule FerryWeb.PipelineInstrumenter do
  @moduledoc "Prometheus instrmenter for Phoenix"

  use Prometheus.PlugPipelineInstrumenter

  def label_value(:request_path, conn) do
    case Phoenix.Router.route_info(
           FerryWeb.Router,
           conn.method,
           conn.request_path,
           ""
         ) do
      %{route: path} -> path
      _ -> "unkown"
    end
  end
end

defmodule FerryWeb.RepoInstrumenter do
  @moduledoc "Prometheus instrmenter for Phoenix"

  use Prometheus.EctoInstrumenter
end

defmodule FerryWeb.PrometheusExporter do
  @moduledoc "Prometheus instrmenter for Phoenix"

  use Prometheus.PlugExporter
end
