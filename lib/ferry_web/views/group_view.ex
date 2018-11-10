defmodule FerryWeb.GroupView do
  use FerryWeb, :view

  def has_groups?(groups) do
    length(groups) > 0
  end

  def has_links?(links) do
    length(links) > 0
  end

  def has_projects?(projects) do
    length(projects) > 0
  end

end
