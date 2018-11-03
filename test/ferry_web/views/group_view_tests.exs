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

end
