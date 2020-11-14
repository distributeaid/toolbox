defmodule Ferry.Fixture.DistributeAid do
  @moduledoc """
  Sets up the distribute aid group and an admin user
  """

  def setup(context) do
    {:ok, %{group: group, user: user}} =
      Ferry.Fixture.GroupUserRole.setup(context, %{
        group: "distributeaid",
        user: "admin@distributeaid.org",
        role: "admin"
      })

    # set the distribute aid group and user into a separate scope
    {:ok, Map.merge(context, %{distributeaid: %{group: group, user: user}})}
  end
end
