defmodule Ferry.Features.Steps.Shipments do
  use Ferry.FeatureCase, file: "shipments.feature"

  defgiven ~r/^there are no shipments$/, _vars, %{conn: conn} = state do
    %{
      "data" => %{
        "deleteShipments" => %{
          "successful" => true
        }
      }
    } = graphql(conn, "{ deleteShipments }")

    {:ok, state}
  end

  defwhen ~r/^I count all shipments$/, _vars, %{conn: conn} = state do
    %{
      "data" => %{
        "countShipments" => count
      }
    } = graphql(conn, "{ countShipments }")

    {:ok, %{state | last: count}}
  end

  defwhen ~r/^I query all shipments$/, _vars, %{conn: conn} = state do
    %{
      "data" => %{
        "shipments" => shipments
      }
    } = graphql(conn, "{ shipments }")

    {:ok, %{state | last: shipments}}
  end
end
