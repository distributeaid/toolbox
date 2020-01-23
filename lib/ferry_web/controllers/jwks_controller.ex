defmodule FerryWeb.JWKSController do
  use FerryWeb, :controller

  # Show the list of public keys used for signing JWTs
  # ------------------------------------------------------------

  def show(conn, _params) do
    # Set header Content-Type: text/json; charset=utf-8
    jwtCfg = Application.get_env(:ferry, :jwt)

    json conn, %{
        keys: [
          %{
            alg: "ES256",
            kid: Keyword.fetch!(jwtCfg, :keyId),
            use: "sig",
            key: Keyword.fetch!(jwtCfg, :publicKey),
          }
        ]
      }
  end
end
