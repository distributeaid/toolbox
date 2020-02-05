defmodule FerryWeb.AidItemControllerTest do
  use FerryWeb.ConnCase

  setup do
    # TODO: probably don't need all this fancy, 'realistic' setup
    n = Enum.random(1..5)
    categories = insert_list(n, :item_category)

    n = Enum.random(1..5)
    mods = insert_list(n, :aid_mod)

    items = Enum.flat_map(categories, fn category ->
      n = Enum.random(0..5)
      item_mods = Enum.take_random(mods, n)

      n = Enum.random(1..5)
      insert_list(n, :aid_item, %{category: category, mods: item_mods})
    end)

    conn = build_conn()
    {:ok, conn: conn, categories: categories, items: items, category: hd(categories), item: hd(items)}
  end

  # Errors
  # ----------------------------------------------------------
  # TODO

  # Read
  # ------------------------------------------------------------
  
  describe "index" do
    test "lists all categories & items", %{conn: conn, categories: categories, items: items} do
      conn = get conn, Routes.aid_item_path(conn, :index)
      response = html_response(conn, 200)
      assert Enum.all?(categories, &(response =~ &1.name))
      assert Enum.all?(items, &(response =~ &1.name))
    end
  end

  # Create
  # ------------------------------------------------------------

  describe "new item" do
    test "renders form", %{conn: conn, category: category} do
      conn = get conn, Routes.aid_item_path(conn, :new), category_id: category.id
      assert html_response(conn, 200) =~ "Add A New Item"
    end
  end

  describe "create item" do
    test "redirects to show when data is valid", %{conn: conn, category: category} do
      item_attrs =
        string_params_for(:aid_item)
        |> Map.put("category_id", category.id)
        |> Map.put("mods", [])
      conn = post conn, Routes.aid_item_path(conn, :create), item: item_attrs
      assert redirected_to(conn) == Routes.aid_item_path(conn, :index)

      conn = get conn, Routes.aid_item_path(conn, :index)
      assert html_response(conn, 200) =~ item_attrs["name"]
    end

    test "renders errors when data is invalid", %{conn: conn, category: category} do
      item_attrs =
        string_params_for(:invalid_aid_item)
        |> Map.put("category_id", category.id)
        |> Map.put("mods", [])
      conn = post conn, Routes.aid_item_path(conn, :create), item: item_attrs
      assert html_response(conn, 200) =~ "Add A New Item"
    end
  end

  # Update
  # ------------------------------------------------------------

  describe "edit item" do
    test "renders form for editing chosen item", %{conn: conn, item: item} do
      conn = get conn, Routes.aid_item_path(conn, :edit, item)
      assert html_response(conn, 200) =~ "Edit An Item"
    end    
  end

  describe "update item" do
    test "redirects when data is valid", %{conn: conn, item: item} do
      item_attrs = string_params_for(:aid_item)
      conn = put conn, Routes.aid_item_path(conn, :update, item), item: item_attrs
      assert redirected_to(conn) == Routes.aid_item_path(conn, :index)

      conn = get conn, Routes.aid_item_path(conn, :index)
      assert html_response(conn, 200) =~ item_attrs["name"]
    end

    test "renders errors when data is invalid", %{conn: conn, item: item} do
      item_attrs = string_params_for(:invalid_aid_item)
      conn = put conn, Routes.aid_item_path(conn, :update, item), item: item_attrs
      assert html_response(conn, 200) =~ "Edit An Item"
    end
  end

  # Delete
  # ------------------------------------------------------------

  describe "delete item" do
    test "deletes chosen item", %{conn: conn, item: item} do
      conn = delete conn, Routes.aid_item_path(conn, :delete, item)
      assert redirected_to(conn) == Routes.aid_item_path(conn, :index)

      conn = get conn, Routes.aid_item_path(conn, :index)
      refute html_response(conn, 200) =~ item.name
    end

    test "renders errors when deletion is invalid", %{conn: conn, item: item} do
      _entry = insert(:list_entry, %{item: item})
      conn = delete conn, Routes.aid_item_path(conn, :delete, item)
      assert redirected_to(conn) == Routes.aid_item_path(conn, :index)

      conn = get conn, Routes.aid_item_path(conn, :index)
      assert html_response(conn, 200) =~ item.name
      assert html_response(conn, 200) =~ "Items linked to aid list entries cannot be deleted, since doing so would destroy user-data."
    end
  end

end