defmodule Ferry.GroupsSteps do
  use Cabbage.Feature

  defgiven ~r/^there are no groups$/, _vars, state do
    mutation(state, "deleteGroups")
  end

  defgiven ~r/^a "(?<name>[^"]+)" group$/, %{name: name}, state do
    mutation!(
      state,
      "createGroup",
      """
        createGroup(
          groupInput: {
            name: "#{name}",
            slug: "#{name}",
            description: "a test group",
            slackChannelName: "#{name}",
            requestForm: "https://distributeaid.org/forms/request",
            requestFormResults: "https://distributeaid.org/forms/request/results",
            volunteerForm: "https://distributeaid.org/forms/volunteer",
            volunteerFormResults: "https://distributeaid.org/forms/volunteer/results",
            donationForm: "https://distributeaid.org/forms/donation",
            donationFormResults: "https://distributeaid.org/forms/donation/results",
            addresses: []
          }
        ) {
          successful
          messages {
            field
            message
          }
          result {
            id,
            name,
            type
          }
        }
      """,
      as: "#{name}_group"
    )
  end
end
