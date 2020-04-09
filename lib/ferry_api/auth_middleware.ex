defmodule FerryApi.Middleware.RequireUser do
  @behaviour Absinthe.Middleware

  alias FerryApi.Constants

  def call(resolution, _opts) do
    case resolution.context.user_id do
      nil ->
        resolution
        |> Absinthe.Resolution.put_result(
          {:error, message: "Not authorized", code: Constants.unauthorized()}
        )

      _ ->
        resolution
    end
  end
end
