defmodule Ferry.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Profiles.Group

  schema "users" do
    field(:email, :string)
    field(:cognito_id, :string)

    # on_delete set in database via migration
    belongs_to(:group, Group)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :cognito_id])
    |> validate_required([:email, :cognito_id])
    |> validate_length(:email, min: 5, max: 255)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> unique_constraint(:cognito_id)
  end
end
