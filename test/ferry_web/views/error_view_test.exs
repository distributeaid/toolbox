defmodule FerryWeb.ErrorViewTest do
  use FerryWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "check_bad_group_id /groups/hello " do
    assert {:error, "Page Not Found"} == check_bad_group_id("/groups/hello")
  end

  test "renders 404.html" do
    assert render_to_string(FerryWeb.ErrorView, "404.html", []) ==
           "Page Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(FerryWeb.ErrorView, "500.html", []) ==
           "Internal Server Error"
  end
end
