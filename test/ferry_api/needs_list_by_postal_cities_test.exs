defmodule Ferry.NeedsListByCities do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.NeedsListByCities
  import Ferry.Expectations.ListEntry

  setup context do
    insert(:user)
    |> mock_sign_in

    Ferry.Fixture.NeedsListAggregation.single_entry(context)
  end

  describe "needs list by cities" do
    test "aggregates amounts", %{
      conn: conn,
      london: london,
      leeds: leeds
    } do
      %{
        "data" => %{
          "currentNeedsListByCities" => %{
            "entries" => entries
          }
        }
      } =
        get_current_needs_list_by_cities(conn, %{
          cities: [london.address.city, leeds.address.city]
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
          "currentNeedsListByCities" => %{
            "entries" => entries
          }
        }
      } =
        get_current_needs_list_by_cities(conn, %{
          cities: [london.address.city]
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
          "needsListByCities" => %{
            "entries" => entries
          }
        }
      } =
        get_needs_list_by_cities(conn, %{
          cities: [london.address.city, leeds.address.city],
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
          "needsListByCities" => %{
            "entries" => []
          }
        }
      } =
        get_needs_list_by_cities(conn, %{
          cities: [london.address.city, leeds.address.city],
          from: DateTime.utc_now() |> DateTime.add(-48 * 3600, :second),
          to: DateTime.utc_now() |> DateTime.add(-24 * 3600, :second)
        })
    end
  end
end
