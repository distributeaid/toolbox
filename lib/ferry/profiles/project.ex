defmodule Ferry.Profiles.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.Profiles.Group

  # alias Ferry.Locations.Address

  @type t :: %__MODULE__{}

  schema "projects" do
    field :name, :string
    field :description, :string

    belongs_to :group, Group

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

  @doc false
  def address_changeset(project, attrs) do
    project
    |> cast(attrs, [])
    |> cast_assoc(:address, required: true, with: &Ferry.Locations.Address.full_changeset/2)
  end
end
