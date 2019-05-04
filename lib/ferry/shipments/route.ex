defmodule Ferry.Shipments.Route do
  use Ecto.Schema
  import Ecto.Changeset


  schema "routes" do
    field :address, :string
    field :date, :string
    field :groups, :string

    timestamps()
  end

  @doc false
  def changeset(route, attrs) do
    route
    |> cast(attrs, [:address, :date, :groups])
    |> validate_required([:address, :date, :groups])
  end
end
