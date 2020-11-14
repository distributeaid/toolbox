defmodule Ferry.Fixture.GroupUserRole do
  @doc """
  A fixture that creates a group, a user, and a membership
  for that user in that group, with the given role
  """
  alias Ferry.Profiles
  alias Ferry.Accounts

  def setup(context, %{group: group, user: email, role: role}) do
    # create a group
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

    # create the user
    {:ok, user} = Accounts.create_user(%{email: email})

    # add the user to the group, using the given role
    {:ok, user} = Accounts.set_user_role(user, group, role)

    {:ok, Map.merge(context, %{group: group, user: user})}
  end
end
