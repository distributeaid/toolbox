defmodule Ferry.Profiles.Group do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Accounts.User
  alias Ferry.Profiles.Group.Logo
  alias Ferry.Profiles.Project


  schema "groups" do
    field :name, :string
    field :description, :string
    field :logo, Logo.Type

    has_one :users, User # on_delete set in database via migration
    has_many :projects, Project # on_delete set in database via migration

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 255)
    |> unique_constraint(:name)
  end

  @doc false
  def logo_changeset(group, attrs) do
    group
    |> cast_attachments(attrs, [:logo])
  end
end
