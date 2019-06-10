# Based on: https://blog.danielberkompas.com/2017/01/17/reusable-templates-in-phoenix/
defmodule FerryWeb.ComponentView do
  use FerryWeb, :view

  alias Ferry.Profiles.Group
  alias Ferry.Profiles.Group.Logo

  def render("group_logo.partial.html", %{group: %Group{} = group} = assigns) do
    version = assigns[:version] # optional
    size = assigns[:size] # optional
    fill = assigns[:fill] # optional
 
    version = case version do
      :original -> :original
      :thumb -> :thumb
      _ -> :thumb
    end

    size_class = case size do
      :large -> "logo--big"
      :small -> "logo--small"
      _ -> ""
    end

    cond do
      group.logo ->
        img_tag Logo.url({group.logo, group}, version),
          alt: "#{group.name}'s Logo",
          class: "logo #{size_class}"

      # fill with blank space if there is no logo
      fill -> ~E(<span class="logo <%= size_class %> logo--filler"><i class="fas fa-fw fa-lg fa-question"></i></span>)

      # do nothing if there is no logo and fill != true
      true -> nil
    end
  end


end