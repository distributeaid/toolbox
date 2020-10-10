defmodule Ferry.Fixture.ShipmentWithPackage do
  import Ferry.ApiClient.{Group, Address, Shipment, Package}

  def setup(%{conn: conn} = context) do
    %{
      "data" => %{
        "createGroup" => %{
          "successful" => true,
          "result" => %{
            "id" => pickup_group
          }
        }
      }
    } = create_simple_group(conn, %{name: "pickup"})

    %{
      "data" => %{
        "createGroup" => %{
          "successful" => true,
          "result" => %{
            "id" => delivery_group
          }
        }
      }
    } = create_simple_group(conn, %{name: "delivery"})

    %{
      "data" => %{
        "createAddress" => %{
          "successful" => true,
          "result" => %{
            "id" => pickup_address
          }
        }
      }
    } = create_address(conn, %{group: pickup_group, label: "pickup"})

    %{
      "data" => %{
        "createAddress" => %{
          "successful" => true,
          "result" => %{
            "id" => delivery_address
          }
        }
      }
    } = create_address(conn, %{group: delivery_group, label: "delivery"})

    %{
      "data" => %{
        "createShipment" => %{
          "successful" => true,
          "result" => %{
            "id" => shipment
          }
        }
      }
    } =
      create_shipment(conn, %{
        pickup: pickup_address,
        delivery: delivery_address
      })

    %{
      "data" => %{
        "createPackage" => %{
          "successful" => true,
          "result" => %{
            "id" => package
          }
        }
      }
    } =
      create_package(conn, %{
        shipment: shipment
      })

    {:ok,
     Map.merge(context, %{
       shipment: shipment,
       package: package
     })}
  end
end
