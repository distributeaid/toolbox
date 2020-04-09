defmodule FerryWeb.Plugs.PutUserId do
  import Plug.Conn

  def aws_client, do: Application.get_env(:ferry, :aws_client)

  def put_user_id(conn, _opts) do
    user_id =
      conn
      |> get_req_header("authorization")
      |> case do
        ["Bearer " <> token] -> token
        _ -> nil
      end
      |> validate_token

    conn
    |> Absinthe.Plug.put_options(context: %{user_id: user_id})
  end

  defp validate_token(nil), do: nil

  defp validate_token(token) do
    token
    |> Ferry.Cognito.get_user()
    |> aws_client().request()
    |> case do
      {:ok, %{"Username" => user_id}} -> user_id
      _ -> nil
    end
  end
end
