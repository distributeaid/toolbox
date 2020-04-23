defmodule FerryWeb.Plugs.PutUser do
  import Plug.Conn

  alias Ferry.Accounts.User
  alias Ferry.Repo

  def put_user(conn, _opts) do
    user =
      conn
      |> get_req_header("authorization")
      |> case do
        ["Bearer " <> token] -> token
        _ -> nil
      end
      |> get_user

    conn
    |> Absinthe.Plug.put_options(context: %{user: user})
  end

  defp get_user(nil), do: nil

  defp get_user(token) do
    token
    |> Ferry.Cognito.validate_user()
    |> insert_or_update_user
  end

  defp insert_or_update_user(nil), do: nil

  defp insert_or_update_user(attrs) do
    {:ok, user} =
      User
      |> Repo.get_by(cognito_id: attrs.cognito_id)
      |> case do
        nil -> %User{}
        user -> user
      end
      |> User.changeset(attrs)
      |> Repo.insert_or_update()

    user
  end
end
