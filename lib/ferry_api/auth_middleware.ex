defmodule FerryApi.Middleware.RequireUser do
  @behaviour Absinthe.Middleware

  # alias FerryApi.Constants

  def call(resolution, _opts) do
    resolution
    # case Application.get_env(:ferry, :auth) do
    #   "enable" ->
    #     case resolution.context.user do
    #       nil ->
    #         resolution
    #         |> Absinthe.Resolution.put_result(
    #           {:error, message: "Not authorized", code: Constants.unauthorized()}
    #         )

    #       _ ->
    #         resolution
    #     end

    #   _ ->
    #     resolution
    # end
  end
end
