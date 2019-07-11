defmodule Ferry.Profiles.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.Profiles.Group
  alias Ferry.Locations.Address


  schema "projects" do
    field :name, :string
    field :description, :string

    has_one :address, Address, on_replace: :update # on_delete set in database via migration
    belongs_to :group, Group # on_delete set in database via migration

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description])

    # NOTE: This will just validate the address fields, not geocoding. You must
    #       call `address_changeset` after looking up geocode data.
    |> cast_assoc(:address, required: true)

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
