defmodule FerryWeb.ProjectView do
  use FerryWeb, :view

  alias Ferry.Profiles.Group.Logo

  def has_projects?(projects) do
    length(projects) > 0
  end

  # TODO: copied from group_view.ex, either import or move the related template
  #       code into a group partial and call in that context
  def logo_url(group) do
    Logo.url({"logo.png", group}, :thumb)
  end
end
