defmodule FerryWeb.Plugs.PutUser do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    case conn |> get_req_header("authorization") |> build_context() do
      {:ok, context} ->
        put_private(conn, :absinthe, %{context: context})

      {:error, _reason} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{error: "unauthorized"}))
        |> halt()

      _ ->
        conn
    end
  end

  defp build_context([]), do: :ok

  defp build_context(["Bearer " <> token]) do
    with {:ok, user} <- authenticate(token) do
      {:ok, %{user: user}}
    end
  end

  defp build_context(_), do: {:error, :invalid_token}

  defp authenticate(token) do
    case Ferry.Token.verify_token(token) do
      {:ok, claims} -> insert_or_update_user(claims)
      {:error, reason} -> {:error, reason}
    end
  end

  # Look for a user in our database. If not found
  # we need to create one
  defp insert_or_update_user(%{"email" => _} = claims) do
    Ferry.Accounts.insert_or_update_user(claims)
  end

  defp insert_or_update_user(_) do
    {:error, :missing_email}
  end
end
