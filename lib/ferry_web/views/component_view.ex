# Based on: https://blog.danielberkompas.com/2017/01/17/reusable-templates-in-phoenix/
defmodule FerryWeb.ComponentView do
  use FerryWeb, :view

  alias Ferry.Profiles.Group
  alias Ferry.Profiles.Group.Logo

  def render("group_logo.partial.html", %{conn: conn, group: %Group{} = group} = assigns) do
    size = assigns[:size] # optional
    fill = assigns[:fill] # optional

    {version, size_class} = case size do
      :xxl -> {:original, "avatar-xxl"}
      :xl -> {:thumb, "avatar-xl"}
      :lg -> {:thumb, "avatar-lg"}
      :normal -> {:thumb, ""}
      _ -> {:thumb, ""}
    end

    cond do
      group.logo -> content_tag :figure, class: "avatar #{size_class}" do
        img_tag Routes.static_path(conn, "/images/1x1.png"),
          alt: "Logo: #{group.name}",
          class: "lazy",
          data: [src: Logo.url({group.logo, group}, version)]
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
