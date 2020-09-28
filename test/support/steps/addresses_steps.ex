defmodule Ferry.AddressesSteps do
  use Cabbage.Feature

  defgiven ~r/^there are no addresses$/, _vars, state do
    mutation(state, "deleteAddresses")
  end

  defgiven ~r/^a (?<name>\w+) address$/, %{name: name}, state do
    group = state_at!(state, "#{name}_group.id")

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
          postal_code: "SA33 5LP"
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
end
