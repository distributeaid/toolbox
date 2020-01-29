defmodule Ferry.Chat.ChatPipeline do
  @moduledoc """
  A pipeline that injects (meta) tags to initialize the in-app chat
  """
  use Guardian.Plug.Pipeline,
    otp_app: :ferry,
    error_handler: Ferry.Auth.ErrorHandler,
    module: Ferry.Auth.Guardian
  
  defp assign_chat_jwt(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    if user do
      # Create JWT here
      jwtCfg = Application.get_env(:ferry, :jwt)
      signer = Joken.Signer.create("ES256", %{"key_pem" => Keyword.fetch!(jwtCfg, :privateKey)})
      extra_claims = %{"user_id" => user.id}
      token_with_default_plus_custom_claims = Ferry.Token.generate_and_sign!(extra_claims, signer)
      assign(conn, :chat_jwt, token_with_default_plus_custom_claims)
    else
      conn
    end
  end

  # If there is a session token, restrict it to an access token and validate it
  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}

  # If there is an authorization header, restrict it to an access token and validate it
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}

  # Load the user if either of the verifications worked
  plug Guardian.Plug.LoadResource, allow_blank: true

  # Provide a JWT for the user so they can use it for the chat
  plug :assign_chat_jwt
end