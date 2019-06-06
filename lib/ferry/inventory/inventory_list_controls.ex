defmodule Ferry.Inventory.InventoryListControls do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :group_filter, {:array, :any}
  end

  @doc false
  def changeset(controls, attrs \\ %{}) do
    controls
    |> cast(attrs, [:group_filter])
    # TODO: validate controls, results
  end
end
