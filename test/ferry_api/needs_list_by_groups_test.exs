defmodule Ferry.NeedsListByGroups do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.NeedsListByGroups
  import Ferry.Expectations.ListEntry

  setup context do
    insert(:user)
    |> mock_sign_in

    Ferry.Fixture.NeedsListAggregation.single_entry(context)
  end

  describe "needs list by groups" do
    test "aggregates amounts", %{
      conn: conn,
      london: london,
      leeds: leeds
    } do
      %{
        "data" => %{
          "currentNeedsListByGroups" => %{
            "entries" => entries
          }
        }
      } =
        get_current_needs_list_by_groups(conn, %{
          groups: [london.group.id, leeds.group.id]
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
          "needsListByGroups" => %{
            "entries" => entries
          }
        }
      } =
        get_needs_list_by_groups(conn, %{
          groups: [london.group.id, leeds.group.id],
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
          "needsListByGroups" => %{
            "entries" => []
          }
        }
      } =
        get_needs_list_by_groups(conn, %{
          groups: [london.group.id, leeds.group.id],
          from: DateTime.utc_now() |> DateTime.add(-48 * 3600, :second),
          to: DateTime.utc_now() |> DateTime.add(-24 * 3600, :second)
        })
    end
  end
end
