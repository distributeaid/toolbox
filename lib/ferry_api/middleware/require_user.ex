defmodule FerryApi.Middleware.RequireUser do
  @behaviour Absinthe.Middleware

  def call(%{context: %{user: _user}} = resolution, _opts) do
    resolution
  end

  def call(resolution, _opts), do: resolution
end
