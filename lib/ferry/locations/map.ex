defmodule Ferry.Locations.Map do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.Locations.Address

  schema "maps" do
    field :search, :string, virtual: true

    field :country_filter, {:array, :string}, virtual: true
    field :group_filter, {:array, :integer}, virtual: true
    field :project_filter, {:array, :integer}, virtual: true

    field :results, {:array, :any}, virtual: true
  end

  @doc false
  def changeset(map, attrs) do
    map
    |> cast(attrs, [:search, :country_filter, :group_filter, :project_filter, :results])
    # TODO: validate country filter, results, etc
  end
end
