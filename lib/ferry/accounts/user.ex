defmodule Ferry.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Comeonin.Bcrypt

  alias Ferry.Profiles.Group


  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    belongs_to :group, Group # on_delete set in database via migration

    timestamps()
  end

  @doc false
  # Based on: https://itnext.io/user-authentication-with-guardian-for-phoenix-1-3-web-apps-e2064cac0ec1
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_length(:email, min: 5, max: 255)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_length(:password, min: 12)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, encrypt_password(password))

      _ ->
        changeset
    end
  end

  @doc """
  TODO
  """
  def encrypt_password(password) do
    Bcrypt.hashpwsalt(password)
  end
end
