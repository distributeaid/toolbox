defmodule FerryWeb.ProjectViewTest do
  use FerryWeb.ConnCase, async: true

  alias FerryWeb.ProjectView

  test "has_projects/1 determines if there are projects or not" do
    projects = []
    refute ProjectView.has_projects? projects

    # a pretend project...
    # since fixtures aren't setup in this testing file yet
    projects = [%{name: "Feed The People"}]
    assert ProjectView.has_projects? projects
  end

end
