defmodule Ferry.ShipmentsSteps do
  use Cabbage.Feature

  defgiven ~r/^there are no shipments$/, _vars, state do
    mutation(state, "deleteShipments")
  end

  defwhen ~r/^I count all shipments$/, _vars, state do
    query(state, "countShipments")
  end

  defwhen ~r/^I query all shipments$/, _vars, state do
    query(state, "shipments", """
      shipments { id }
    """)
  end

  defgiven ~r/^a shipment from (?<sender>\w+) to (?<receiver>\w+)$/,
           %{sender: _sender, receiver: _receiver},
           state do
    pickup_address = state_at!(state, "sender_address.id")
    delivery_address = state_at!(state, "receiver_address.id")

    mutation!(state, "createShipment", """
    createShipment(
      shipmentInput: {
        pickupAddress: "#{pickup_address}",
        deliveryAddress: "#{delivery_address}",
        description: "a shipment",
        transportType: "pallets",
        availableFrom: "#{DateTime.utc_now() |> DateTime.to_iso8601()}",
        targetDelivery: "#{
      DateTime.utc_now() |> DateTime.add(2 * 24 * 3600, :second) |> DateTime.to_iso8601()
    }"
      }
    ){
      successful,
        messages { field, message },
        result {
          id
        }
    }
    """)
  end
end
