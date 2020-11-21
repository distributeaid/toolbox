defmodule Ferry.Fixture.DistributeAid do
  @moduledoc """
  Sets up the distribute aid group and an admin user
  """

  def setup(context, opts \\ []) do
    {:ok, %{group: group, user: user} = context} =
      Ferry.Fixture.UserRole.setup(
        context,
        %{
          group: "distributeaid",
          user: "admin@distributeaid.org",
          role: "admin"
        },
        opts
      )

    # set the distribute aid group and user into a separate scope
    {:ok, Map.put(context, :distributeaid, %{group: group, user: user})}
  end
end
