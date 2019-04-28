defmodule FerryWeb.ErrorViewTest do
  use FerryWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 400.html error" do
    assert render_to_string(FerryWeb.ErrorView, "error_page.html", [error: "400", reason: "Bad Request"]) =~
             "Bad Request"
  end

  test "renders 401.html" do
    assert render_to_string(FerryWeb.ErrorView, "error_page.html", [error: "401", reason: "Not Authorized to View"]) =~
             "Not Authorized to View"
  end

  test "renders 403.html" do
    assert render_to_string(FerryWeb.ErrorView, "error_page.html", [error: "403", reason: "Forbidden Page"]) =~
             "Forbidden Page"
  end

  test "renders 404.html with a group id error" do
    assert render_to_string(FerryWeb.ErrorView, "error_page.html",  [error: "404", reason: "A group with the ID 8 does not exist"]) =~
             "A group with the ID 8 does not exist"
  end

  test "renders 404.html with a path, but not group id error" do
    assert render_to_string(FerryWeb.ErrorView, "error_page.html",  [error: "404", reason: "Page Not Found"]) =~
             "Page Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(FerryWeb.ErrorView, "error_page.html", [error: "500", reason: "Internal Server Error"]) =~
             "Internal Server Error"
  end
end
