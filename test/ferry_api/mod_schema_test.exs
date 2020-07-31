defmodule Ferry.ModSchemaTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.Mod

  test "count mods where there are none", %{conn: conn} do
    assert count_mods(conn) ==
             %{"data" => %{"countMods" => 0}}
  end
end
