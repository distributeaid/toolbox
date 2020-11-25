defmodule Ferry.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.Accounts.UserGroup

  @type t() :: %__MODULE__{}

  schema "users" do
    field(:email, :string)
    has_many :groups, UserGroup, foreign_key: :user_id
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> validate_length(:email, min: 5, max: 255)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
