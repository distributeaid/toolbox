defmodule FerryWeb.JWKSControllerTest do
  use FerryWeb.ConnCase

  describe "show" do
    test "lists public keys used for signing JWTs", %{conn: conn} do
      conn = get conn, Routes.jwks_path(conn, :show)
      response = json_response(conn, 200)
      assert Map.has_key?(response, "keys")
      assert length(response["keys"]) == 1

      key_entry = hd(response["keys"])
      assert key_entry["key"] =~ "PUBLIC"
      refute key_entry["key"] =~ "PRIVATE"
    end
  end
end
