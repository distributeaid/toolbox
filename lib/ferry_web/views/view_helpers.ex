# Based on: https://blog.danielberkompas.com/2017/01/17/reusable-templates-in-phoenix/
defmodule FerryWeb.ViewHelpers do

  # ComponentView Shortcut Functions
  # ------------------------------------------------------------
  # Based on: https://blog.danielberkompas.com/2017/01/17/reusable-templates-in-phoenix/
  def component(template) do
    FerryWeb.ComponentView.render(template)
  end

  def component(template, assigns) do
    FerryWeb.ComponentView.render(template, assigns)
  end

  def component(template, assigns, do: block) do
    FerryWeb.ComponentView.render(template, Keyword.merge(assigns, [do: block]))
  end

  # Form Helpers
  # ------------------------------------------------------------
  def get_id(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.get_field(changeset, :id)
  end
end
