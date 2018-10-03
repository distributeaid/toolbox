defmodule Ferry.CRM.Email do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.CRM.Contact


  schema "emails" do
    field :email, :string

    belongs_to :contact, Contact # on_replace set in Contact schema, on_delete set in database via migration

    timestamps()
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> validate_length(:email, min: 5, max: 255)
    |> validate_format(:email, ~r/@/)
  end
end
