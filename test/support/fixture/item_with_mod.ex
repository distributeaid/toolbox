defmodule Ferry.Fixture.ItemWithMod do
  import Ferry.ApiClient.Mod

  def setup(%{conn: conn, item: item, size: mod} = context) do
    %{
      "data" => %{
        "addModToItem" => %{
          "successful" => true
        }
      }
    } =
      add_mod_to_item(conn, %{
        item: item,
        mod: mod
      })

    {:ok, context}
  end
end
