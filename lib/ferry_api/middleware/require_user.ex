defmodule FerryApi.Middleware.RequireUser do
  @doc """
  Simple GraphQL middleware that checks
  for a valid user in the current scope.
  """
  @behaviour Absinthe.Middleware
  alias Ferry.Accounts.User

  def call(%{context: %{user: %User{}}} = resolution, _opts) do
    resolution
  end

  def call(resolution, _opts) do
    resolution
    |> Absinthe.Resolution.put_result({:error, "unauthorized"})
  end
end
