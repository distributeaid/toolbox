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
      shipments {
        id,
        pickup_address {
          id
        },
        delivery_address {
          id
        },
        status,
        description,
        transport_type,
        available_from,
        target_delivery
      }
    """)
  end

  defgiven ~r/^a shipment from (?<pickup>\w+) to (?<delivery>\w+)$/,
           %{pickup: pickup, delivery: delivery},
           state do
    pickup_address = context_at!(state, "#{pickup}_address.id")
    delivery_address = context_at!(state, "#{delivery}_address.id")

    mutation!(
      state,
      "createShipment",
      """
      createShipment(
        shipmentInput: {
          pickupAddress: "#{pickup_address}",
          deliveryAddress: "#{delivery_address}",
          status: "planning",
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
            id,
            pickup_address {
              id
            },
            delivery_address {
              id
            },
            status,
            description,
            transport_type,
            available_from,
            target_delivery
          }
      }
      """,
      as: "shipment"
    )
  end

  defwhen ~r/^I update that shipment$/, _vars, state do
    shipment = context_at!(state, "shipment")

    mutation(state, "updateShipment", """
    updateShipment(
      id: "#{shipment["id"]}"
      shipmentInput: {
        pickupAddress: "#{shipment["pickup_address"]["id"]}",
        deliveryAddress: "#{shipment["delivery_address"]["id"]}",
        status: "#{shipment["status"]}",
        description: "#{shipment["description"]}",
        transportType: "#{shipment["transport_type"]}",
        availableFrom: "#{shipment["available_from"]}",
        targetDelivery: "#{shipment["target_delivery"]}"
      }
    ){
      successful,
        messages { field, message },
        result {
          id,
          pickup_address {
            id
          },
          delivery_address {
            id
          },
          status,
          description,
          transport_type,
          available_from,
          target_delivery,
          packages {
            id,
            number,
            amount,
            contents,
            type
          }
        }
    }
    """)
  end

  defwhen ~r/^I get that shipment$/, _vars, state do
    shipment = context_at!(state, "shipment")

    query(state, "shipment", """
    shipment(id: "#{shipment["id"]}") {
      id,
      pickup_address { id },
      delivery_address { id },
      status,
      description,
      transport_type,
      available_from,
      target_delivery,
      packages {
        id,
        number,
        amount,
        contents,
        type
      }
    }
    """)
  end

  defgiven ~r/^shipment status "(?<status>[^"]+)"$/, %{status: status}, state do
    shipment =
      state
      |> context_at!("shipment")
      |> Map.put("status", status)

    state
    |> with_context("shipment", shipment)
  end

  defgiven ~r/^an unknown shipment (?<name>\w+) address$/, %{name: name}, state do
    shipment =
      state
      |> context_at!("shipment")
      |> Map.put("#{name}_address", %{"id" => "999"})

    state
    |> with_context("shipment", shipment)
  end

  defgiven ~r/^that's the shipment (?<name>\w+) address$/, %{name: name}, state do
    shipment =
      state
      |> context_at!("shipment")
      |> Map.put("#{name}_address", state.result)

    state
    |> with_context("shipment", shipment)
  end

  defwhen ~r/^I delete that shipment$/, _vars, state do
    shipment = context_at!(state, "shipment")

    mutation(state, "deleteShipment", """
    deleteShipment(id: "#{shipment["id"]}") {
      successful,
      messages {
        field,
        message
      },
      result {
        id
      }
    }
    """)
  end
end
