defmodule Ferry.Fixture.Group do
  @doc """
  A fixture that creates a group

  """
  alias Ferry.Profiles

  def setup(context, %{group: group}, _opts \\ []) do
    {:ok, group} =
      Profiles.create_group(%{
        name: group,
        slug: group,
        description: group,
        slack_channel_name: group,
        request_form: "https://nodomain.com/forms",
        request_form_results: "https://nodomain.com/forms",
        volunteer_form: "https://nodomain.com/forms",
        volunteer_form_results: "https://nodomain.com/forms",
        donation_form: "https://nodomain.com/forms",
        donation_form_results: "https://nodomain.com/forms"
      })

    {:ok, Map.put(context, :group, group)}
  end
end
