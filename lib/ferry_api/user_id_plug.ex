defmodule FerryAPI.UserIdPlug do
  import Plug.Conn

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
