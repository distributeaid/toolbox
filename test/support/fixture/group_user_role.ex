defmodule Ferry.Fixture.GroupUserRole do
  @doc """
  A fixture that creates a group, a user, and a membership
  for that user in that group, with the given role.

  """
  alias Ferry.Profiles

  def setup(context, %{group: group, user: email, role: role}, opts \\ []) do
    # create a group
    {:ok, _} =
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

    Ferry.Fixture.UserRole.setup(
      context,
      %{
        group: group,
        user: email,
        role: role
      },
      opts
    )
  end
end
