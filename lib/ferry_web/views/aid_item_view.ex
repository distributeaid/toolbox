defmodule FerryWeb.AidItemView do
  use FerryWeb, :view

  alias Ferry.AidTaxonomy.Item

  def friendly(%Item{} = item, :mods) do
    item.mods |> Enum.map(&(&1.name)) |> Enum.join(", ")
  end

  def item_has_mod(%Ecto.Changeset{} = changeset, mod) do
    mods = Ecto.Changeset.get_field(changeset, :mods, [])
    Enum.any?(mods, &(&1.id == mod.id))
  end
end
