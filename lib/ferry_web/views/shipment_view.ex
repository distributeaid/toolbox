defmodule FerryWeb.ShipmentView do
  use FerryWeb, :view

  def has_shipments?(shipments) do
    length(shipments) > 0
  end

  def items_text(shipment) do
    cond do
      shipment.items != nil -> shipment.items
      shipment.funding != nil -> shipment.funding
      true -> "There is nothing to describe this shipment yet"
    end
  end
end
