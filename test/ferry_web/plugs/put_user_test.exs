defmodule FerryWeb.PutUserPlugTest do
  use FerryWeb.ConnCase

  alias FerryWeb.Plugs.PutUser
  alias Ferry.Accounts

  defp with_token(conn, token) do
    conn
    |> put_req_header("authorization", token)
    |> PutUser.call(%{})
  end

  defp with_bearer_token(conn, token) do
    with_token(conn, "Bearer #{token}")
  end

  defp as_token(claims) do
    {:ok, token, ^claims} = Ferry.Token.encode_and_sign(claims)
    token
  end

  describe "PutUser plug" do
    test "accepts requests with no authorization header", %{conn: conn} do
      conn =
        conn
        |> PutUser.call(%{})

      refute conn.status
    end

    test "returns a 401 if authorization header is present but has no value", %{conn: conn} do
      conn =
        conn
        |> with_token("")

      assert 401 == conn.status
    end

    test "returns a 401 if the token is not a bearer token", %{conn: conn} do
      conn =
        conn
        |> with_token("not a bearer")

      assert 401 == conn.status
    end

    test "returns a 401 if the token is forged", %{conn: conn} do
      token =
        %{id: "1", email: "foo@bar.com"}
        |> as_token()
        |> String.replace("a", "A")

      conn =
        conn
        |> with_bearer_token(token)

      assert 401 == conn.status
    end

    test "returns a 401 if the token expired", %{conn: conn} do
      token =
        %{id: "1", email: "foo@bar.com", exp: 0}
        |> as_token()

      conn =
        conn
        |> with_bearer_token(token)

      assert 401 == conn.status
    end

    test "returns a 401 if no email is present in claims", %{conn: conn} do
      token =
        %{id: "1"}
        |> as_token()

      conn =
        conn
        |> with_bearer_token(token)

      assert 401 == conn.status
    end

    test "inserts a new user if no user with that email is found", %{conn: conn} do
      assert [] == Accounts.get_users()

      token =
        %{id: "1", email: "foo@bar.com"}
        |> as_token()

      conn =
        conn
        |> with_bearer_token(token)

      refute conn.status

      [user] = Accounts.get_users()
      assert "foo@bar.com" == user.email
    end

    test "updates the existing user", %{conn: conn} do
      assert {:ok, user} = Accounts.create_user(%{email: "foo@bar.com"})
      assert [user] == Accounts.get_users()

      token =
        %{id: "1", email: "foo@bar.com"}
        |> as_token()

      conn =
        conn
        |> with_bearer_token(token)

      refute conn.status

      [user] = Accounts.get_users()
      assert "foo@bar.com" == user.email
    end
  end
end
