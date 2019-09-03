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
      :large -> "avatar-xxl"
      :small -> "avatar-lg"
      _ -> ""
    end

    cond do
      group.logo -> content_tag :figure, class: "avatar #{size_class}" do
        img_tag Logo.url({group.logo, group}, version), alt: "#Logo: {group.name}"
      end

      # fill with blank space if there is no logo
      fill -> content_tag :figure, class: "avatar avatar--filler #{size_class}" do
        ~E(<i class="fas fa-fw fa-lg fa-question"></i>)
      end

      # do nothing if there is no logo and fill != true
      true -> nil
    end
  end


end
