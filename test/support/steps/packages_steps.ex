defmodule Ferry.PackagesSteps do
  use Cabbage.Feature

  # This step populates the current context with a
  # map of default values for a package. This step
  # is designed so that the same details can be modified
  # by subsequent steps in the same scenario
  defgiven ~r/^a package$/, _vars, state do
    state
    |> with_context("package", %{
      "type" => "pallet",
      "number" => 1,
      "width" => 600,
      "height" => 166,
      "length" => 800,
      "contents" => "something",
      "amount" => 1,
      "stackable" => true,
      "dangerous" => false
    })
  end

  defwhen ~r/^that package is in that shipment$/, _vars, state do
    shipment = context_at!(state, "shipment")
    package = context_at!(state, "package")

    mutation!(
      state,
      "createPackage",
      """
      createPackage(
        packageInput: {
          shipment: "#{shipment["id"]}",
          number: #{package["number"]},
          type: "#{package["type"]}",
          contents: "#{package["contents"]}",
          amount: #{package["amount"]},
          width: #{package["width"]},
          height: #{package["height"]},
          length: #{package["length"]},
          stackable: #{package["stackable"]},
          dangerous: #{package["dangerous"]}
        }
      ){
        successful,
          messages { field, message },
          result {
            id,
            shipment {
              id
            },
            number,
            type,
            contents,
            amount,
            width,
            height,
            length,
            stackable,
            dangerous
          }
      }
      """,
      as: :package
    )
  end

  defwhen ~r/^I create that package$/, _vars, state do
    shipment = context_at!(state, "shipment")
    package = context_at!(state, "package")

    mutation(
      state,
      "createPackage",
      """
      createPackage(
        packageInput: {
          shipment: "#{shipment["id"]}",
          number: #{package["number"]},
          type: "#{package["type"]}",
          contents: "#{package["contents"]}",
          amount: #{package["amount"]},
          width: #{package["width"]},
          height: #{package["height"]},
          length: #{package["length"]},
          stackable: #{package["stackable"]},
          dangerous: #{package["dangerous"]}
        }
      ){
        successful,
          messages { field, message },
          result {
            id,
            shipment {
              id
            },
            number,
            type,
            contents,
            amount,
            width,
            height,
            length,
            stackable,
            dangerous
          }
      }
      """,
      as: :package
    )
  end

  defwhen ~r/^I delete that package$/, _vars, state do
    package = context_at!(state, "package")

    mutation(state, "deletePackage", """
    deletePackage(id: "#{package["id"]}") {
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
