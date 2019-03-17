defmodule Ferry.Locations.Map do
  use Ecto.Schema
  import Ecto.Changeset

  schema "maps" do
    # control data
    field :group_filter_labels, {:array, :any}, virtual: true

    # controls
    field :search, :string, virtual: true
    field :country_filter, {:array, :string}, virtual: true
    field :group_filter, {:array, :integer}, virtual: true

    # results
    field :results, {:array, :any}, virtual: true
  end

  @doc false
  def changeset(map, attrs) do
    map
    |> cast(attrs, [:group_filter_labels, :search, :country_filter, :group_filter, :results])
    |> validate_required([:group_filter_labels])
    # TODO: validate controls, results
  end
end
