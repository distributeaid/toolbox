defmodule Ferry.CRM.Phone do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.CRM.Contact


  schema "phones" do
    # TODO: add proper support for country_codes, see: http://country.io/data/
    field :country_code, :string
    field :number, :string

    belongs_to :contact, Contact

    timestamps()
  end

  @doc false
  def changeset(phone, attrs) do
    phone
    |> cast(attrs, [:country_code, :number])
    |> validate_required([:country_code, :number])
    |> validate_length(:country_code, min: 1, max: 255)
    |> validate_length(:number, min: 1, max: 255)
  end
end
