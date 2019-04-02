defmodule FerryWeb.StockControllerTest do
  use FerryWeb.ConnCase

  alias Ferry.Inventory

  @create_attrs %{count: 42, description: "some description", package_count: 42, photo: "some photo"}
  @update_attrs %{count: 43, description: "some updated description", package_count: 43, photo: "some updated photo"}
  @invalid_attrs %{count: nil, description: nil, package_count: nil, photo: nil}

  def fixture(:stock) do
    {:ok, stock} = Inventory.create_stock(@create_attrs)
    stock
  end

  describe "index" do
    test "lists all inventory_stocks", %{conn: conn} do
      conn = get conn, stock_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Inventory stocks"
    end
  end

  describe "new stock" do
    test "renders form", %{conn: conn} do
      conn = get conn, stock_path(conn, :new)
      assert html_response(conn, 200) =~ "New Stock"
    end
  end

  describe "create stock" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, stock_path(conn, :create), stock: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == stock_path(conn, :show, id)

      conn = get conn, stock_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Stock"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, stock_path(conn, :create), stock: @invalid_attrs
      assert html_response(conn, 200) =~ "New Stock"
    end
  end

  describe "edit stock" do
    setup [:create_stock]

    test "renders form for editing chosen stock", %{conn: conn, stock: stock} do
      conn = get conn, stock_path(conn, :edit, stock)
      assert html_response(conn, 200) =~ "Edit Stock"
    end
  end

  describe "update stock" do
    setup [:create_stock]

    test "redirects when data is valid", %{conn: conn, stock: stock} do
      conn = put conn, stock_path(conn, :update, stock), stock: @update_attrs
      assert redirected_to(conn) == stock_path(conn, :show, stock)

      conn = get conn, stock_path(conn, :show, stock)
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, stock: stock} do
      conn = put conn, stock_path(conn, :update, stock), stock: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Stock"
    end
  end

  describe "delete stock" do
    setup [:create_stock]

    test "deletes chosen stock", %{conn: conn, stock: stock} do
      conn = delete conn, stock_path(conn, :delete, stock)
      assert redirected_to(conn) == stock_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, stock_path(conn, :show, stock)
      end
    end
  end

  defp create_stock(_) do
    stock = fixture(:stock)
    {:ok, stock: stock}
  end
end
