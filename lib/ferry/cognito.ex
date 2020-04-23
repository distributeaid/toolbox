defmodule Ferry.Cognito do
  @moduledoc """
  AWS Cognito Identity Provider
  """

  @doc """
  Gets the specified user by token
  Requires developer credentials.
  """

  @namespace "AWSCognitoIdentityProviderService"

  def aws_client, do: Application.get_env(:ferry, :aws_client)

  def validate_user(token) do
    token
    |> build_request()
    |> aws_client().request()
    |> case do
      {:ok, cognito_reponse} -> cognito_reponse
      _ -> nil
    end
    |> parse_response
  end

  defp build_request(access_token) do
    request("GetUser", %{"AccessToken" => access_token})
  end

  defp request(action, data) do
    headers = [
      {"x-amz-target", "#{@namespace}.#{action}"},
      {"content-type", "application/x-amz-json-1.1"}
    ]

    ExAws.Operation.JSON.new(:"cognito-idp", data: data, headers: headers)
  end

  defp parse_response(nil), do: nil

  defp parse_response(%{"Username" => cognito_id, "UserAttributes" => attributes}) do
    attributes
    |> Enum.map(fn %{"Name" => key, "Value" => value} -> {key, value} end)
    |> Map.new()
    |> case do
      %{"email_verified" => "true", "email" => email} -> %{email: email, cognito_id: cognito_id}
      _ -> nil
    end
  end
end
