defmodule FerryWeb.ProjectView do
  use FerryWeb, :view

  def has_projects?(projects) do
    length(projects) > 0
  end
end
