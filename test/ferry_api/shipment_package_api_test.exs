defmodule Ferry.ShipmentPackageApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.Shipment

  setup context do
    {:ok, context} = Ferry.Fixture.DistributeAid.setup(context, auth: true)
    Ferry.Fixture.ShipmentWithPackage.setup(context)
  end

  describe "shipment and packages api" do
    test "returns shipments with their packages", %{
      conn: conn,
      shipment: shipment,
      package: package
    } do
      %{
        "data" => %{
          "shipments" => [
            %{
              "id" => ^shipment,
              "packages" => [
                %{"id" => ^package}
              ]
            }
          ]
        }
      } = get_shipments(conn)
    end

    test "cannot delete a shipment that has packages", %{
      conn: conn,
      shipment: id
    } do
      %{
        "data" => %{
          "deleteShipment" => %{
            "successful" => false,
            "messages" => [
              error
            ]
          }
        }
      } = delete_shipment(conn, id)

      assert "has packages" == error["message"]
    end
  end
end
