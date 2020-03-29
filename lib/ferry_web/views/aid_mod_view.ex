defmodule FerryWeb.AidModView do
  use FerryWeb, :view

  alias Ferry.AidTaxonomy.Mod

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

  def values_select(%Phoenix.HTML.Form{} = form, %Ecto.Changeset{} = changeset) do
    values = Ecto.Changeset.get_field(changeset, :values)
    values = if is_nil(values), do: [], else: values

    # NOTE: we want to select all existing values, so that they are all present unless the user chooses to remove one
    multiple_select form, :values, values, selected: values, multiple: true, class: "form-select select2--aid-mod-values"
  end
end
