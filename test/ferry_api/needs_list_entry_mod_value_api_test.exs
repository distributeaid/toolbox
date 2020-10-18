defmodule Ferry.NeedsListEntryModValueApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.{NeedsListEntryModValue}

  setup context do
    insert(:user)
    |> mock_sign_in

    {:ok, context} = Ferry.Fixture.NeedsListWithEntry.setup(context)
    {:ok, context} = Ferry.Fixture.ModWithModValues.setup(context)
    Ferry.Fixture.ItemWithMod.setup(context)
  end

  describe "needs list entry mod value graphql api" do
    test "adds and removes existing mod values to existing needs list entries", %{
      conn: conn,
      entry: entry,
      small: small
    } do
      %{
        "data" => %{
          "addModValueToNeedsListEntry" => %{
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
        add_mod_value_to_needs_list_entry(conn, %{
          entry: entry,
          mod_value: small
        })

      %{
        "data" => %{
          "removeModValueFromNeedsListEntry" => %{
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
        remove_mod_value_from_needs_list_entry(conn, %{
          entry: entry,
          mod_value: small
        })
    end
  end
end
