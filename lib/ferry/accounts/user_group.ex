defmodule Ferry.Accounts.UserGroup do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.Accounts.User
  alias Ferry.Profiles.Group

  @type t() :: %__MODULE__{}

  schema "user_groups" do
    belongs_to :user, User, foreign_key: :user_id
    belongs_to :group, Group, foreign_key: :group_id
    field(:role, :string)
    timestamps()
  end

  @required_fields [:user_id, :group_id, :role]
  @allowed_roles ["admin", "member"]

  @doc false
  def changeset(user_group, attrs) do
    user_group
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:role, @allowed_roles)
    |> unique_constraint([:user, :group],
      name: :unique_role_per_user_per_group,
      message: "already exists"
    )
  end
end
