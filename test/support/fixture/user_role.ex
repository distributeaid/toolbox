defmodule Ferry.Fixture.UserRole do
  @doc """
  A fixture that creates a user, and a membership
  for that user in that group, with the given role.

  The group lookup is by slug.
  """
  alias Ferry.Profiles
  alias Ferry.Accounts

  def setup(context, %{group: group, user: email, role: role}) do
    # find the group by its slug
    {:ok, group} = Profiles.get_group_by_slug(group)

    # create the user
    {:ok, user} = Accounts.create_user(%{email: email})

    # add the user to the group, using the given role
    {:ok, user} = Accounts.set_user_role(user, group, role)

    {:ok, Map.merge(context, %{group: group, user: user})}
  end
end
