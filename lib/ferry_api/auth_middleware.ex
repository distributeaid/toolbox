defmodule FerryApi.Middleware.RequireUser do
  @behaviour Absinthe.Middleware

  alias FerryApi.Constants

  @auth_enabled? Application.get_env(:ferry, :auth) == "enable"

  def call(resolution, _opts) do
    case @auth_enabled? do
      false ->
        resolution

      true ->
        case resolution.context.user do
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
end
