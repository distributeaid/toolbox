defmodule Ferry.CognitoTest do
  use Ferry.DataCase
  import Mox

  alias Ferry.Cognito

  test "cognito responds :ok" do
    Ferry.Mocks.AwsClient
    |> expect(:request, fn _args ->
      {:ok,
       %{
         "Username" => "test_user",
         "UserAttributes" => [
           %{"Name" => "email_verified", "Value" => "true"},
           %{"Name" => "email", "Value" => "user@example.com"}
         ]
       }}
    end)

    assert {:ok, _} = Cognito.validate_user("fake token")
  end

  test "email not verified" do
    Ferry.Mocks.AwsClient
    |> expect(:request, fn _args ->
      {:ok,
       %{
         "Username" => "test_user",
         "UserAttributes" => [
           %{"Name" => "email_verified", "Value" => "false"},
           %{"Name" => "email", "Value" => "user@example.com"}
         ]
       }}
    end)

    assert {:error, _} = Cognito.validate_user("fake token")
  end

  test "cognito responds with something else" do
    Ferry.Mocks.AwsClient
    |> expect(:request, fn _args ->
      {:not_ok, "something bad happened"}
    end)

    assert {:error, _} = Cognito.validate_user("fake token")
  end
end
