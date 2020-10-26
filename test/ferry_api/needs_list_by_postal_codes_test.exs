defmodule Ferry.NeedsListByPostalCodes do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.NeedsListByPostalCodes
  import Ferry.Expectations.ListEntry

  setup context do
    insert(:user)
    |> mock_sign_in

    Ferry.Fixture.NeedsListAggregation.single_entry(context)
  end

  describe "needs list by postal_codes" do
    test "aggregates amounts", %{
      conn: conn,
      london: london,
      leeds: leeds
    } do
      %{
        "data" => %{
          "currentNeedsListByPostalCodes" => %{
            "entries" => entries
          }
        }
      } =
        get_current_needs_list_by_postal_codes(conn, %{
          postal_codes: [london.address.postal_code, leeds.address.postal_code]
        })

      assert_entry(
        %{
          amount: 8,
          item: "shirt",
          mods: %{size: "large", color: "red"}
        },
        entries
      )

      %{
        "data" => %{
          "currentNeedsListByPostalCodes" => %{
            "entries" => entries
          }
        }
      } =
        get_current_needs_list_by_postal_codes(conn, %{
          postal_codes: [london.address.postal_code]
        })

      assert_entry(
        %{
          amount: 4,
          item: "shirt",
          mods: %{size: "large", color: "red"}
        },
        entries
      )

      %{
        "data" => %{
          "needsListByPostalCodes" => %{
            "entries" => entries
          }
        }
      } =
        get_needs_list_by_postal_codes(conn, %{
          postal_codes: [london.address.postal_code, leeds.address.postal_code],
          from: DateTime.utc_now() |> DateTime.add(-24 * 3600, :second),
          to: DateTime.utc_now() |> DateTime.add(24 * 3600, :second)
        })

      assert_entry(
        %{
          amount: 8,
          item: "shirt",
          mods: %{size: "large", color: "red"}
        },
        entries
      )

      %{
        "data" => %{
          "needsListByPostalCodes" => %{
            "entries" => []
          }
        }
      } =
        get_needs_list_by_postal_codes(conn, %{
          postal_codes: [london.address.postal_code, leeds.address.postal_code],
          from: DateTime.utc_now() |> DateTime.add(-48 * 3600, :second),
          to: DateTime.utc_now() |> DateTime.add(-24 * 3600, :second)
        })
    end
  end
end
