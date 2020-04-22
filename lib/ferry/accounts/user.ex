defmodule Ferry.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Profiles.Group

  schema "users" do
    field(:email, :string)

    # on_delete set in database via migration
    belongs_to(:group, Group)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
