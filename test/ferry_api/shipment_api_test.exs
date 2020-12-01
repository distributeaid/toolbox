defmodule Ferry.ShipmentApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.{Group, Address, Shipment}

  setup context do
    {:ok, %{conn: conn} = context} = Ferry.Fixture.DistributeAid.setup(context, auth: true)

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

    {:ok,
     Map.merge(context, %{
       shipment: shipment,
       pickup: %{group: pickup_group, address: pickup_address},
       delivery: %{group: delivery_group, address: delivery_address}
     })}
  end

  describe "shipments graphql api" do
    test "returns all shipments", %{conn: conn, shipment: shipment} do
      %{
        "data" => %{
          "shipments" => [
            %{"id" => ^shipment}
          ]
        }
      } = get_shipments(conn)
    end

    test "fetches a shipment", %{conn: conn, shipment: id} do
      %{
        "data" => %{
          "shipment" => %{"id" => ^id}
        }
      } = get_shipment(conn, id)
    end

    test "deletes a shipment", %{conn: conn, shipment: id} do
      %{
        "data" => %{
          "deleteShipment" => %{
            "successful" => true
          }
        }
      } = delete_shipment(conn, id)

      %{
        "data" => %{
          "shipment" => nil
        }
      } = get_shipment(conn, id)
    end

    test "does not update a shipment with an invalid address", %{
      conn: conn,
      shipment: id,
      delivery: delivery
    } do
      %{
        "data" => %{
          "updateShipment" => %{
            "successful" => false,
            "messages" => [error]
          }
        }
      } =
        update_shipment(conn, %{
          id: id,
          pickup: "999",
          delivery: delivery.address
        })

      assert "pickup address not found" == error["message"]
    end

    test "does not update a shipment with an invalid status", %{
      conn: conn,
      shipment: id,
      pickup: pickup,
      delivery: delivery
    } do
      %{
        "data" => %{
          "updateShipment" => %{
            "successful" => false,
            "messages" => [error]
          }
        }
      } =
        update_shipment(conn, %{
          id: id,
          status: "invalid",
          pickup: pickup.address,
          delivery: delivery.address
        })

      assert "is invalid" == error["message"]
      assert "status" == error["field"]
    end

    test "updates a shipment with a valid address", %{
      conn: conn,
      pickup: pickup,
      delivery: delivery,
      shipment: id
    } do
      %{
        "data" => %{
          "createAddress" => %{
            "successful" => true,
            "result" => %{
              "id" => pickup_address_2
            }
          }
        }
      } = create_address(conn, %{group: pickup.group, label: "pickup2"})

      %{
        "data" => %{
          "updateShipment" => %{
            "successful" => true,
            "result" => %{
              "pickupAddress" => %{"id" => ^pickup_address_2}
            }
          }
        }
      } =
        update_shipment(conn, %{
          id: id,
          pickup: pickup_address_2,
          delivery: delivery.address
        })
    end
  end
end
