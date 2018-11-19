# Based on: https://blog.danielberkompas.com/2017/01/17/reusable-templates-in-phoenix/
defmodule FerryWeb.ComponentHelpers do
  def component(template, assigns) do
    FerryWeb.ComponentView.render(template, assigns)
  end
  
  def component(template, assigns, do: block) do
    FerryWeb.ComponentView.render(template, Keyword.merge(assigns, [do: block]))
  end
end