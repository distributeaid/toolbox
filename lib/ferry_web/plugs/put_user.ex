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
      # deconstruct a list of all the groups
      # the user belongs to
      user_groups = Enum.map(user.groups, fn ug -> ug.group end)

      # check whether or not this is a da amin
      da_admin =
        Enum.find(user.groups, nil, fn ug ->
          ug.role == "admin" and ug.group.id == 0
        end) != nil

      {:ok, %{user: user, user_groups: user_groups, da_admin: da_admin}}
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
