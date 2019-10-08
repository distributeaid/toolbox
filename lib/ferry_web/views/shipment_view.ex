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
end
