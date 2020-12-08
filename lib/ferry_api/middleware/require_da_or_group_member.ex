defmodule FerryApi.Middleware.RequireDaOrGroupMember do
  @doc """
  Composite GraphQL middleware that checks for a
  DistributeAid admin, or a group member.

  Relies on existing middleware.
  """
  @behaviour Absinthe.Middleware
  alias FerryApi.Middleware.{RequireDaAdmin, RequireGroupMember}

  def call(resolution, opts) do
    with %{errors: [_ | _]} <- RequireDaAdmin.call(resolution, opts) do
      RequireGroupMember.call(resolution, opts)
    end
  end
end
