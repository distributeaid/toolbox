defmodule FerryApi.Middleware.RequireDaAdmin do
  @doc """
  Simple GraphQL middleware that checks whether or
  not the user performing an action is a DistributeAid
  admin.

  We rely on the fact that we know the DistributeAid
  group exists and has id "0".
  """
  @behaviour Absinthe.Middleware

  def call(%{context: %{user: user}} = resolution, _opts) do
    case Ferry.Accounts.has_role?(user, "0", "admin") do
      true ->
        resolution

      false ->
        resolution
        |> Absinthe.Resolution.put_result({:error, "unauthorized"})
    end
  end

  def call(resolution, _opts) do
    resolution
    |> Absinthe.Resolution.put_result({:error, "unauthorized"})
  end
end
