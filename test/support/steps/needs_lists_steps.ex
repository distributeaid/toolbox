defmodule Ferry.NeedsListsSteps do
  use Cabbage.Feature

  defwhen ~r/^I create a "(?<name>[^"]+)" needs list$/, %{name: name}, state do
    project = context_at!(state, "#{name}_project.id")
    from = context_at!(state, "from_date") |> DateTime.to_iso8601()
    to = context_at!(state, "to_date") |> DateTime.to_iso8601()

    mutation(
      state,
      "createNeedsList",
      """
      createNeedsList(
        needsListInput: {
          project: "#{project}",
          from: "#{from}",
          to: "#{to}"
        }
      ) {
        successful
        messages {
          field
          message
        }
        result {
          id,
          project {
            id,
            group {
              id
            }
          }
          from,
          to
        }
      }
      """,
      as: "#{name}_needs_list"
    )
  end
end
