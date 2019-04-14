defmodule FerryWeb.ErrorViewTest do
  use FerryWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 400.html error" do
    assert render_to_string(FerryWeb.ErrorView, "400_page.html", []) =~
             "Bad Request"
  end

  test "renders 401.html" do
    assert render_to_string(FerryWeb.ErrorView, "401_page.html", []) =~
             "Not Authorized to View"
  end

  test "renders 403.html" do
    assert render_to_string(FerryWeb.ErrorView, "403_page.html", []) =~
             "Forbidden Page"
  end

  test "renders 404.html with a group id error" do
    assert render_to_string(FerryWeb.ErrorView, "404_page.html",  %{conn: %{path_info: ["public","groups","8"] }}) =~
             "A group with the ID 8 does not exist"
  end

  test "renders 404.html with a path, but not group id error" do
    assert render_to_string(FerryWeb.ErrorView, "404_page.html",  %{conn: %{path_info: ["groups","here"] }}) =~
             "Page Not Found"
  end

  test "renders 404.html" do
    assert render_to_string(FerryWeb.ErrorView, "404.html", []) ==
             "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(FerryWeb.ErrorView, "500.html", []) ==
             "Internal Server Error"
  end
end
