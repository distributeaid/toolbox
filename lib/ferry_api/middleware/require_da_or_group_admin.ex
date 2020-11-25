defmodule FerryApi.Middleware.RequireDaOrGroupAdmin do
  @doc """
  Composite GraphQL middleware that checks for a
  DistributeAid admin, or a group admin.

  Relies on existing middleware.
  """
  @behaviour Absinthe.Middleware
  alias FerryApi.Middleware.{RequireDaAdmin, RequireGroupAdmin}

  def call(resolution, opts) do
    with %{errors: [_ | _]} <- RequireDaAdmin.call(resolution, opts) do
      RequireGroupAdmin.call(resolution, opts)
    end
  end
end
