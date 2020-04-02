defmodule FerryWeb.Plugs do
  import Plug.Conn

  alias Ferry.Profiles

  # Assign Current Group
  # ------------------------------------------------------------
  # NOTE: assumes Ferry.Auth.SetupPipeline has already been called in the router pipeline
  def assign_current_group(%{assigns: %{current_user: %{group_id: group_id}}} = conn, _opts) do
    assign(conn, :current_group, Profiles.get_group!(group_id))
  end

  def assign_current_group(conn, _opts) do
    assign(conn, :current_group, nil)
  end

  def assign_chat_meta(%{assigns: %{current_user: %{id: user_id, email: email}}} = conn, _opts) do
    # If we are on a known route (e.g. shipments or groups)
    secondToLastPathElement = conn.path_info |> Enum.at(-2)
    additionalSectionsWithChat = ["shipments", "groups"]
    extraContext = if additionalSectionsWithChat |> Enum.find(fn el -> el == secondToLastPathElement end) != nil
    and conn.path_params["id"] != nil
    do
      # construct the context identifier for this context
      "#{secondToLastPathElement}-#{conn.path_params["id"]}" # shipments-42, groups-17
    end
    # Default context is "general", but if we are on a known context
    context = if extraContext do extraContext else "general" end
    # By default all users have access to the room "general"
    contexts = if extraContext do ["general", extraContext] else ["general"] end
    # Create JWT here
    jwtCfg = Application.get_env(:ferry, :jwt)
    pem = Keyword.fetch!(jwtCfg, :privateKey)
    kid = Keyword.fetch!(jwtCfg, :keyId)
    signer = Joken.Signer.create("ES256", %{"pem" => pem}, %{"kid" => kid})
    token = Ferry.Token.generate_and_sign!(%{
      "contexts" => contexts,
      "sub" => Integer.to_string(user_id),
      "email" => email,
      "exp" => System.system_time(:second) + (60 * 60)
      }, signer)

    assign(conn, :chat_meta, %{token: token, context: context})
  end

  def assign_chat_meta(conn, _opts) do
    conn
  end

  def put_user_id(conn) do
    user_id = conn
    |> get_req_header("authorization")
    |> case do
      ["Bearer " <> token] -> token
      _ -> nil
    end
    |> validate_token

    assign(conn, :user_id, user_id)
  end

  defp validate_token(nil), do: nil

  defp validate_token(token) do
    token
    |> Ferry.Cognito.get_user()
    |> ExAws.request()
    |> IO.inspect()
    |> case do
      {:ok, _} -> "me"
      _ -> nil
    end
  end

end
