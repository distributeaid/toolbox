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

  # only hash when necessary
  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, encrypt_password(password))

      _ ->
        changeset
    end
  end

  defp put_password_hash(changeset), do: changeset

  @doc """
  TODO

  Expose this step so it is accessible in tests.
  """
  def encrypt_password(password) do
    Bcrypt.hashpwsalt(password)
  end
end
