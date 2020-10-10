defmodule Ferry.ProjectsSteps do
  use Cabbage.Feature

  defgiven ~r/^a "(?<name>[^"]+)" project$/, %{name: name}, state do
    group = context_at!(state, "#{name}_group.id")

    mutation!(
      state,
      "createProject",
      """
        createProject(
          projectInput: {
            group: "#{group}",
            name: "#{name} project",
            description: "#{name} project"
          }
        ) {
          successful
          messages {
            field
            message
          }
          result {
            id,
            group {
              id
            },
            name,
            description
          }
        }
      """,
      as: "#{name}_project"
    )
  end
end
