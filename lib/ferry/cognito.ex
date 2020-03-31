defmodule Ferry.Cognito do
  @moduledoc """
  AWS Cognito Identity Provider
  """

  @doc """
  Gets the specified user by token
  Requires developer credentials.
  """

  @namespace "AWSCognitoIdentityProviderService"

  @spec get_user(access_token :: String.t()) :: ExAws.Operation.JSON.t()
  def get_user(access_token) do
    request("GetUser", %{"AccessToken" => access_token})
  end

  defp request(action, data) do
    headers = [
      {"x-amz-target", "#{@namespace}.#{action}"},
      {"content-type", "application/x-amz-json-1.1"}
    ]

    ExAws.Operation.JSON.new(:"cognito-idp", data: data, headers: headers)
  end
end
