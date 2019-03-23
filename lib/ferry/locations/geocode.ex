defmodule Ferry.Locations.Geocode do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.Locations.Address


  schema "geocodes" do
    field :lat, :string
    field :lng, :string
    field :data, :map

    belongs_to :address, Address # on_delete set in database via migration

    timestamps()
  end

  # TODO: Investigate Nominatim return values and validate them to ensure the
  #       data is correct. https://wiki.openstreetmap.org/wiki/Nominatim#Search

  @doc false
  def changeset(geocode, attrs) do
    geocode
    |> cast(attrs, [:lat, :lng, :data])
    |> validate_required([:lat, :lng, :data])
  end
end
