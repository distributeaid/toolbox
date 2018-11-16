defmodule Ferry.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false

  alias Comeonin.Bcrypt

  alias Ferry.Repo
  alias Ferry.Auth.Guardian
  alias Ferry.Accounts.User

  @doc """
  TODO
  """
  def authenticate_user(email, plain_text_password) do
    Repo.get_by(User, email: email)
    |> check_password(plain_text_password)
  end

  defp check_password(nil, _) do
    Bcrypt.dummy_checkpw()
    {:error, :invalid_credentials}
  end

  defp check_password(%User{} = user, plain_text_password) do
    if Bcrypt.checkpw(plain_text_password, user.password_hash) do
      {:ok, user}
    else
      {:error, :invalid_credentials}
    end
  end
end
