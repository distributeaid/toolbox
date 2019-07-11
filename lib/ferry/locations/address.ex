defmodule Ferry.Locations.Address do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.Locations.Geocode
  alias Ferry.Profiles.{Group, Project}


  schema "addresses" do
    field :label, :string
    field :street, :string
    field :city, :string
    field :state, :string
    field :country, :string
    field :zip_code, :string

    has_one :geocode, Geocode, on_replace: :update # on_delete set in database via migration

    belongs_to :group, Group # on_delete set in database via migration
    belongs_to :project, Project # on_delete set in database via migration

    timestamps()
  end

  @doc false
  def changeset(address, attrs) do
    address
    |> cast(attrs, [:label, :street, :city, :state, :country, :zip_code])
    |> validate_required([:label, :city, :country])
    |> validate_length(:label, min: 1, max: 255)
    |> validate_length(:street, max: 255)
    |> validate_length(:city, min: 1, max: 255)
    |> validate_length(:state, max: 255)
    |> validate_length(:country, min: 2, max: 255) # must be at least a 2 letter country code
    |> validate_length(:zip_code, max: 255)
    # TODO: add a changeset check constraint that matches the db one?
    #       https://hexdocs.pm/ecto/Ecto.Changeset.html#check_constraint/3
    #
    # TODO: test format for some fields (letters / whitespace only?)
  end

  @doc false
  def geocode_changeset(address, attrs) do
    address
    |> cast(attrs, [])
    |> cast_assoc(:geocode, required: true)
  end

  @doc false
  def full_changeset(address, attrs) do
    address
    |> cast(attrs, [:label, :street, :city, :state, :country, :zip_code])
    |> cast_assoc(:geocode, required: true)
    |> validate_required([:label, :city, :country])
    |> validate_length(:label, min: 1, max: 255)
    |> validate_length(:street, max: 255)
    |> validate_length(:city, min: 1, max: 255)
    |> validate_length(:state, max: 255)
    |> validate_length(:country, min: 2, max: 255) # must be at least a 2 letter country code
    |> validate_length(:zip_code, max: 255)
    # TODO: add a changeset check constraint that matches the db one?
    #       https://hexdocs.pm/ecto/Ecto.Changeset.html#check_constraint/3
    #
    # TODO: test format for some fields (letters / whitespace only?)
  end

end
