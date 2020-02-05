defmodule FerryWeb.AidModView do
  use FerryWeb, :view

  alias Ferry.Aid.Mod

  def friendly(%Mod{} = mod, :type) do
    case mod.type do
      "integer" -> "Number"
      "select" -> "Select"
      "multi-select" -> "Multi-Select"
    end
  end

  def friendly(%Mod{} = mod, :values) do
    case mod.type do
      "integer" -> nil
      "select" -> Enum.join(mod.values, ", ")
      "multi-select" -> Enum.join(mod.values, ", ")
    end
  end

  def friendly(%Mod{} = mod, :items) do
    mod.items |> Enum.map(&(&1.name)) |> Enum.join(", ")
  end

  def mod_has_item(%Ecto.Changeset{} = changeset, item) do
    items = Ecto.Changeset.get_field(changeset, :items, [])
    Enum.any?(items, &(&1.id == item.id))
  end
end
