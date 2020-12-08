defmodule Ferry.Fixture.GroupUserRole do
  @doc """
  A fixture that creates a group, a user, and a membership
  for that user in that group, with the given role.

  """

  def setup(context, %{group: group, user: email, role: role} = args, opts \\ []) do
    {:ok, context} = Ferry.Fixture.Group.setup(context, args)

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
