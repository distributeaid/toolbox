defmodule FerryWeb.Telemetry.Absinthe do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    events = [
      [:absinthe, :resolve, :field, :stop]
    ]

    :telemetry.attach_many("absinthe-telemetry", events, &__MODULE__.handle_event/4, [])
    {:ok, opts}
  end

  def handle_event(event, measurements, meta, _config) do
    # TODO: translate this event into a metric that
    # we can publish to Datadog or Prometheus
    %{
      event_name: event,
      measurements: measurements,
      definition: meta.resolution.definition.name
    }
  end
end
