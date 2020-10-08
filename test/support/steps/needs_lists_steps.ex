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

  defgiven ~r/^a "(?<name>[^"]+)" needs lists$/, %{name: name}, state do
    project = context_at!(state, "#{name}_project.id")
    from = context_at!(state, "from_date") |> DateTime.to_iso8601()
    to = context_at!(state, "to_date") |> DateTime.to_iso8601()

    mutation!(
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

  defwhen ~r/^I update the "(?<name>[^"]+)" needs list$/, %{name: name}, state do
    needs_list = context_at!(state, "#{name}_needs_list.id")
    project = context_at!(state, "#{name}_project.id")
    from = context_at!(state, "from_date") |> DateTime.to_iso8601()
    to = context_at!(state, "to_date") |> DateTime.to_iso8601()

    mutation(
      state,
      "updateNeedsList",
      """
      updateNeedsList(
        id: "#{needs_list}",
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

    # Your implementation here
  end
end
