defmodule FerryWeb.ErrorViewTest do
  use FerryWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  setup do
    {:ok, conn: Phoenix.ConnTest.conn()}
  end

  test "renders 404.html with a group id error" do
    assert render_to_string(FerryWeb.ErrorView, "404.html",  %{conn: %{path_info: ["public","groups","8"] }}) =~
             "A group with the ID 8 does not exist"
  end

  test "renders 404.html with a path, but not group id error" do
    assert render_to_string(FerryWeb.ErrorView, "404.html",  %{conn: %{path_info: ["groups","here"] }}) =~
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
