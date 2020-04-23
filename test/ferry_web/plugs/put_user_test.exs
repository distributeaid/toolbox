defmodule FerryWeb.PutUserPlugTest do
  use FerryWeb.ConnCase
  import Mox

  alias FerryWeb.Plugs.PutUser

  describe "no valid user" do
    test "no authorization token", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "")
        |> PutUser.put_user(%{})

      %{private: %{absinthe: %{context: context}}} = conn

      assert %{user: nil} = context
    end

    test "no bearer token", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "not a bearer")
        |> PutUser.put_user(%{})

      %{private: %{absinthe: %{context: context}}} = conn

      assert %{user: nil} = context
    end

    test "when Cognito rejects token", %{conn: conn} do
      Ferry.Mocks.AwsClient
      |> expect(:request, fn _args ->
        {:not_ok, "something bad happened"}
      end)

      conn =
        conn
        |> put_req_header("authorization", "Bearer asdf")
        |> PutUser.put_user(%{})

      %{private: %{absinthe: %{context: context}}} = conn

      assert %{user: nil} = context
    end
  end

  describe "valid user" do
    test "an existing user", %{conn: conn} do
      user = insert(:user)

      Ferry.Mocks.AwsClient
      |> expect(:request, fn _args ->
        {:ok,
         %{
           "Username" => user.cognito_id,
           "UserAttributes" => [
             %{"Name" => "email_verified", "Value" => "true"},
             %{"Name" => "email", "Value" => user.email}
           ]
         }}
      end)

      conn =
        conn
        |> put_req_header("authorization", "Bearer asdf")
        |> PutUser.put_user(%{})

      %{private: %{absinthe: %{context: context}}} = conn

      assert %{user: user} = context
    end

    test "a user is created when no user with the resulting cognito_id", %{conn: conn} do
      Ferry.Mocks.AwsClient
      |> expect(:request, fn _args ->
        {:ok,
         %{
           "Username" => "new-user-cognito-id",
           "UserAttributes" => [
             %{"Name" => "email_verified", "Value" => "true"},
             %{"Name" => "email", "Value" => "new-user@example.com"}
           ]
         }}
      end)

      conn =
        conn
        |> put_req_header("authorization", "Bearer asdf")
        |> PutUser.put_user(%{})

      new_user =
        Ferry.Accounts.User
        |> Ferry.Repo.get_by(cognito_id: "new-user-cognito-id")

      assert %{email: "new-user@example.com"} = new_user

      %{private: %{absinthe: %{context: context}}} = conn

      assert %{user: new_user} = context
    end
  end
end
