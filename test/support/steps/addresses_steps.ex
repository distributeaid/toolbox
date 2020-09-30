defmodule Ferry.AddressesSteps do
  use Cabbage.Feature

  defgiven ~r/^there are no addresses$/, _vars, state do
    mutation!(state, "deleteAddresses")
  end

  defgiven ~r/^a "(?<name>[^"]+)" address$/, %{name: name}, state do
    group = context_at!(state, "#{name}_group.id")

    mutation!(
      state,
      "createAddress",
      """
      createAddress (
        addressInput: {
          group: #{group},
          label: "#{name}",
          street: "79 Bridge Street",
          city: "Gorllwyn",
          province: "Berkshire",
          country_code: "GB",
          postal_code: "SA33 5LP",
          opening_hour: "9:00",
          closing_hour: "18:00",
          type: "industrial",
          has_loading_equipment: true,
          has_unloading_equipment: true,
          needs_appointment: false
        }
      ) {
          successful,
          messages {
            field,
            message
          },
          result {
            id,
            label
          }
        }

      """,
      as: "#{name}_address"
    )
  end

  defwhen ~r/^I get that address$/, _vars, state do
    address_id = state.result["id"]

    query(state, "address", """
      address(id: "#{address_id}") {
        group {
          id,
          name
        },
        label,
        street,
        city,
        province,
        country_code,
        postal_code,
        opening_hour,
        closing_hour,
        type,
        has_loading_equipment,
        has_unloading_equipment,
        needs_appointment
      }
    """)
  end
end
