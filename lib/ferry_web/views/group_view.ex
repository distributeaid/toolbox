defmodule FerryWeb.GroupView do
  use FerryWeb, :view

  def has_groups?(groups) do
    length(groups) > 0
  end
end
