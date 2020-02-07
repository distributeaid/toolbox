defmodule Ferry.Chat.ChatPipeline do
  @moduledoc """
  A pipeline that injects (meta) tags to initialize the in-app chat
  """
  use Guardian.Plug.Pipeline,
    otp_app: :ferry,
    error_handler: Ferry.Auth.ErrorHandler,
    module: Ferry.Auth.Guardian

  defp assign_chat_meta(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    if user do
      # Create JWT here
      jwtCfg = Application.get_env(:ferry, :jwt)
      pem = Keyword.fetch!(jwtCfg, :privateKey)
      kid = Keyword.fetch!(jwtCfg, :keyId)
      signer = Joken.Signer.create("ES256", %{"pem" => pem}, %{"kid" => kid})
      token = Ferry.Token.generate_and_sign!(%{
        "contexts" => ["general", "random"], 
        "sub" => Integer.to_string(user.id),
        "exp" => System.system_time(:second) + (60 * 60)
        }, signer)
      assign(conn, :chat_meta, token)
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
  plug :assign_chat_meta
end