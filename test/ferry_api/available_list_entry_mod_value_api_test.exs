defmodule Ferry.AvailableListEntryModValueApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.{AvailableListEntryModValue}

  setup context do
    insert(:user)
    |> mock_sign_in

    {:ok, context} = Ferry.Fixture.AvailableListWithEntry.setup(context)
    {:ok, context} = Ferry.Fixture.ModWithModValues.setup(context)
    Ferry.Fixture.ItemWithMod.setup(context)
  end

  describe "available list entry mod value graphql api" do
    test "adds and removes existing mod values to existing available list entries", %{
      conn: conn,
      entry: entry,
      small: small
    } do
      %{
        "data" => %{
          "addModValueToAvailableListEntry" => %{
            "successful" => true,
            "messages" => [],
            "result" => %{
              "id" => _,
              "amount" => 1,
              "modValues" => [%{"modValue" => %{"id" => ^small}}]
            }
          }
        }
      } =
        add_mod_value_to_available_list_entry(conn, %{
          entry: entry,
          mod_value: small
        })

      %{
        "data" => %{
          "removeModValueFromAvailableListEntry" => %{
            "successful" => true,
            "messages" => [],
            "result" => %{
              "id" => _,
              "amount" => 1,
              "modValues" => []
            }
          }
        }
      } =
        remove_mod_value_from_available_list_entry(conn, %{
          entry: entry,
          mod_value: small
        })
    end
  end
end
