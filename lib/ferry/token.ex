defmodule Ferry.Token do
  use Joken.Config
  require Logger

  def setup() do
    token_config = Application.get_env(:ferry, Ferry.Token)

    pem = token_config[:key]

    pem =
      case pem do
        nil ->
          Logger.warn("Missing JWT secret in #{inspect(token_config)}")

        _ ->
          Base.decode64!(pem)
      end

    Application.put_env(
      :joken,
      :default_signer,
      signer_alg: "RS256",
      key_pem: pem
    )
  end

  defp aud(), do: Application.get_env(:ferry, Ferry.Token)[:audience]
  defp iss(), do: Application.get_env(:ferry, Ferry.Token)[:issuer]

  def token_config do
    default_claims(skip: [:aud, :iss])
    |> add_claim("aud", nil, &(&1 == aud()))
    |> add_claim("iss", nil, &(&1 == iss()))
  end

  def verify_token(token) do
    Ferry.Token.verify_and_validate(token)
  end
end
