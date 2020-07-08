defmodule Ferry.CategoryTest do
  use FerryWeb.ConnCase, async: true

  test "count categories where there is none", %{conn: conn} do
    res =
      conn
      |> graphql_query("{ countCategories }")

    %{"data" => %{"countCategories" => count}} = res
    assert count == 0
  end
end
