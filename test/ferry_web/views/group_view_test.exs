defmodule FerryWeb.GroupViewTest do
  use FerryWeb.ConnCase, async: true

  alias FerryWeb.GroupView

  test "has_groups/1 determines if there are groups or not" do
    groups = []
    refute GroupView.has_groups? groups

    # a pretend group...
    # since fixtures aren't setup in this testing file yet
    groups = [%{name: "The Black Panther Party"}]
    assert GroupView.has_groups? groups
  end

  test "has_links/1 determines if there are links or not" do
    links = []
    refute GroupView.has_links? links

    # a pretend project...
    # since fixtures aren't setup in this testing file yet
    links = [%{url: "https://example.org"}]
    assert GroupView.has_links? links
  end

  test "has_projects/1 determines if there are projects or not" do
    projects = []
    refute GroupView.has_projects? projects

    # a pretend project...
    # since fixtures aren't setup in this testing file yet
    projects = [%{name: "Feed The People"}]
    assert GroupView.has_projects? projects
  end

end
