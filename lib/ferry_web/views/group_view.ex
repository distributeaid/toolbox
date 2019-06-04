defmodule FerryWeb.GroupView do
  use FerryWeb, :view

  alias Ferry.Profiles.Group.Logo

  def has_groups?(groups) do
    length(groups) > 0
  end

  def has_links?(links) do
    length(links) > 0
  end

  def has_projects?(projects) do
    length(projects) > 0
  end

  def has_shipments?(shipments) do
    length(shipments) > 0
  end

  def logo_url(group) do
    Logo.url({"logo.png", group}, :thumb)
  end

end
