defmodule FerryWeb.ShipmentView do
  use FerryWeb, :view

  def has_shipments?(shipments) do
    length(shipments) > 0
  end

  def has_routes?(routes) do
    length(routes) > 0
  end

  def one_month_from_today() do
    Timex.now() |> Timex.shift(months: 1) |> Timex.format!("{Mfull} {D}, {YYYY}")
  end

  def status_text(status) do
    case status do
      "ready" -> "Ready To Load"
      _ -> status # single word statuses- css will capitalize
    end
  end

  def status_order(status) do
    case status do
      "planning" -> 1
      "ready" -> 2
      "underway" -> 3
      "received" -> 4
      _ -> 0
    end
  end
end
