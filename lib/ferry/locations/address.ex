defmodule Ferry.Locations.Address do
  use Ecto.Schema
  import Ecto.Changeset


  schema "addresses" do
    field :label, :string
    field :street, :string
    field :city, :string
    field :state, :string
    field :country, :string
    field :zip_code, :string

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
    |> validate_length(:country, min: 1, max: 255)
    |> validate_length(:zip_code, max: 255)
  end
end
