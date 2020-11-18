defmodule FerryApi.Middleware.RequireGroupAdmin do
  @doc """
  Simple GraphQL middleware that checks whether the current
  user is an admin in the group found in the arguments.

  This middleware may be reused in multiple resolvers by
  adding extra function clauses in order to decide where
  in the current scope the relevant group should be taken from.
  """
  @behaviour Absinthe.Middleware

  def call(%{arguments: %{group: group}, context: %{user: user}} = resolution, _opts) do
    case Ferry.Accounts.has_role?(user, group, "admin") do
      true ->
        resolution

      false ->
        resolution
        |> Absinthe.Resolution.put_result({:error, "unauthorized"})
    end
  end
end
