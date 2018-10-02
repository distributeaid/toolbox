defmodule Ferry.Profiles.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.Profiles.Group


  schema "projects" do
    field :name, :string
    field :description, :string

    belongs_to :group, Group # on_delete set in database via migration

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 255)
    |> unique_constraint(:name)
  end
end
