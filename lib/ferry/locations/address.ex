defmodule Ferry.Locations.Address do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.Locations.Geocode
  alias Ferry.Profiles.{Group, Project}

  @type t :: %__MODULE__{}

  schema "addresses" do
    field :label, :string
    field :street, :string
    field :city, :string
    field :province, :string
    field :country_code, :string
    field :postal_code, :string
    field :opening_hour, :string
    field :closing_hour, :string
    field :type, :string
    field :has_loading_equipment, :boolean
    field :has_unloading_equipment, :boolean
    field :needs_appointment, :boolean

    # on_delete set in database via migration
    has_one :geocode, Geocode, on_replace: :update

    # on_delete set in database via migration
    belongs_to :group, Group
    # on_delete set in database via migration
    belongs_to :project, Project

    timestamps()
  end

  @required_fields [
    :label,
    :street,
    :city,
    :province,
    :country_code,
    :postal_code,
    :opening_hour,
    :closing_hour,
    :type,
    :has_loading_equipment,
    :has_unloading_equipment,
    :needs_appointment
  ]

  @address_types [
    "industrial",
    "residential"
  ]

  @doc false
  def changeset(address, attrs) do
    address
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @address_types)
    |> validate_length(:label, min: 1, max: 255)
    |> validate_length(:street, max: 255)
    |> validate_length(:city, min: 1, max: 255)
    |> validate_length(:province, max: 255)
    # must be at least a 2 letter country code
    |> validate_length(:country_code, min: 2, max: 255)
    |> validate_length(:postal_code, max: 255)
    |> unique_constraint(:label, name: :unique_address_label_per_group)

    # TODO: add a changeset check constraint that matches the db one?
    #       https://hexdocs.pm/ecto/Ecto.Changeset.html#check_constraint/3
    #
    # TODO: test format for some fields (letters / whitespace only?)

    # TODO: validate :country_code against ISO list at some point
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
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:geocode, required: true)
    |> validate_length(:label, min: 1, max: 255)
    |> validate_length(:street, max: 255)
    |> validate_length(:city, min: 1, max: 255)
    |> validate_length(:province, max: 255)
    # must be at least a 2 letter country code
    |> validate_length(:country_code, min: 2, max: 255)
    |> validate_length(:postal_code, max: 255)
    |> unique_constraint(:label, name: :unique_address_label_per_group)

    # TODO: add a changeset check constraint that matches the db one?
    #       https://hexdocs.pm/ecto/Ecto.Changeset.html#check_constraint/3
    #
    # TODO: test format for some fields (letters / whitespace only?)
  end

  def full_address(%__MODULE__{
        street: street,
        city: city,
        postal_code: zip,
        country_code: country
      }) do
    Enum.join([street, city, zip, country], " ")
  end
end
