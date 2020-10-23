defmodule Ferry.Fixture.ModWithModValues do
  import Ferry.ApiClient.{Mod, ModValue}

  def setup(%{conn: conn} = context) do
    %{
      "data" => %{
        "createMod" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => size
          }
        }
      }
    } = create_mod(conn, %{name: "size", description: "T-Shirt sizes", type: "select"})

    %{
      "data" => %{
        "createModValue" => %{
          "successful" => true,
          "result" => %{
            "id" => small
          }
        }
      }
    } = create_mod_value(conn, %{value: "small", mod: size})

    %{
      "data" => %{
        "createModValue" => %{
          "successful" => true,
          "result" => %{
            "id" => regular
          }
        }
      }
    } = create_mod_value(conn, %{value: "regular", mod: size})

    {:ok,
     Map.merge(context, %{
       size: size,
       small: small,
       regular: regular
     })}
  end
end
