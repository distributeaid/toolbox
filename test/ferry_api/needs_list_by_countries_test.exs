defmodule Ferry.NeedsListByCountries do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.NeedsListByCountries
  import Ferry.Expectations.ListEntry

  setup context do
    insert(:user)
    |> mock_sign_in

    Ferry.Fixture.NeedsListAggregation.single_entry(context)
  end

  describe "needs list by countries" do
    test "aggregates amounts", %{
      conn: conn,
      london: london,
      leeds: leeds
    } do
      %{
        "data" => %{
          "currentNeedsListByCountries" => %{
            "entries" => entries
          }
        }
      } =
        get_current_needs_list_by_countries(conn, %{
          countries: [london.address.country_code, leeds.address.country_code]
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
          "currentNeedsListByCountries" => %{
            "entries" => entries
          }
        }
      } =
        get_current_needs_list_by_countries(conn, %{
          countries: [london.address.country_code]
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
          "needsListByCountries" => %{
            "entries" => entries
          }
        }
      } =
        get_needs_list_by_countries(conn, %{
          countries: [london.address.country_code, leeds.address.country_code],
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
          "needsListByCountries" => %{
            "entries" => []
          }
        }
      } =
        get_needs_list_by_countries(conn, %{
          countries: [london.address.country_code, leeds.address.country_code],
          from: DateTime.utc_now() |> DateTime.add(-48 * 3600, :second),
          to: DateTime.utc_now() |> DateTime.add(-24 * 3600, :second)
        })
    end
  end
end
