defmodule FerryApi.Middleware.RequireGroupMember do
  @doc """
  Simple GraphQL middleware that checks whether the current
  user is a member in the group found in the arguments.

  """
  @behaviour Absinthe.Middleware

  alias Ferry.Profiles.Group

  def call(%{source: %Group{} = group, context: %{user: user}} = resolution, _opts) do
    case Ferry.Profiles.is_member?(group, user) do
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
