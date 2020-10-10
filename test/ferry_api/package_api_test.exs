defmodule Ferry.PackageApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.Package

  setup context do
    insert(:user)
    |> mock_sign_in

    Ferry.Fixture.ShipmentWithPackage.setup(context)
  end

  describe "packages graphql api" do
    test "fetches a package", %{conn: conn, package: id} do
      %{
        "data" => %{
          "package" => %{"id" => ^id}
        }
      } = get_package(conn, id)
    end

    test "deletes a package", %{conn: conn, package: id} do
      %{
        "data" => %{
          "deletePackage" => %{
            "successful" => true
          }
        }
      } = delete_package(conn, id)

      %{
        "data" => %{
          "package" => nil
        }
      } = get_package(conn, id)
    end

    test "detects conflicts in package numbers", %{
      conn: conn,
      shipment: id
    } do
      %{
        "data" => %{
          "createPackage" => %{
            "successful" => false,
            "messages" => [
              error
            ]
          }
        }
      } =
        create_package(conn, %{
          shipment: id
        })

      assert "already taken" == error["message"]
      assert "number" == error["field"]
    end
  end
end
