defmodule FerryWeb.ShipmentView do
  use FerryWeb, :view

  def has_shipments?(shipments) do
    length(shipments) > 0
  end

  def has_routes?(routes) do
    length(routes) > 0
  end

  def items_text(shipment) do
    cond do
      shipment.label != nil -> shipment.label
      shipment.items != nil -> shipment.items
      true -> "There is nothing to describe this shipment yet"
    end
  end

  def one_month_from_today() do
    Timex.now() |> Timex.shift(months: 1) |> Timex.format!("{Mfull} {D}, {YYYY}")
  end
end
