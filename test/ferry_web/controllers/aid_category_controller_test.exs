defmodule FerryWeb.AidCategoryControllerTest do
  use FerryWeb.ConnCase
  
  setup do
    category = insert(:item_category)

    conn = build_conn()
    {:ok, conn: conn, category: category}
  end

  # Errors
  # ----------------------------------------------------------
  # TODO

  # Read
  # ------------------------------------------------------------
  # No read functions.

  # Create
  # ------------------------------------------------------------

  describe "new category" do
    test "renders form", %{conn: conn} do
      conn = get conn, Routes.aid_category_path(conn, :new)
      assert html_response(conn, 200) =~ "Add A New Category"
    end
  end

  describe "create category" do
    test "redirects to show when data is valid", %{conn: conn} do
      category_attrs = string_params_for(:item_category)
      conn = post conn, Routes.aid_category_path(conn, :create), item_category: category_attrs

      assert redirected_to(conn) == Routes.aid_item_path(conn, :index)

      conn = get conn, Routes.aid_item_path(conn, :index)
      assert html_response(conn, 200) =~ category_attrs["name"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      category_attrs = string_params_for(:invalid_item_category)
      conn = post conn, Routes.aid_category_path(conn, :create), item_category: category_attrs
      assert html_response(conn, 200) =~ "Add A New Category"
    end
  end

  # Update
  # ------------------------------------------------------------

  describe "edit category" do
    test "renders form for editing chosen category", %{conn: conn, category: category} do
      conn = get conn, Routes.aid_category_path(conn, :edit, category)
      assert html_response(conn, 200) =~ "Edit A Category"
    end    
  end

  describe "update category" do
    test "redirects when data is valid", %{conn: conn, category: category} do
      category_attrs = string_params_for(:item_category)
      conn = put conn, Routes.aid_category_path(conn, :update, category), item_category: category_attrs
      assert redirected_to(conn) == Routes.aid_item_path(conn, :index)

      conn = get conn, Routes.aid_item_path(conn, :index)
      assert html_response(conn, 200) =~ category_attrs["name"]
    end

    test "renders errors when data is invalid", %{conn: conn, category: category} do
      category_attrs = string_params_for(:invalid_item_category)
      conn = put conn, Routes.aid_category_path(conn, :update, category), item_category: category_attrs
      assert html_response(conn, 200) =~ "Edit A Category"
    end
  end

  # Delete
  # ------------------------------------------------------------

  describe "delete category" do
    test "deletes chosen category", %{conn: conn, category: category} do
      item = insert(:aid_item, %{category: category})

      conn = delete conn, Routes.aid_category_path(conn, :delete, category)
      assert redirected_to(conn) == Routes.aid_item_path(conn, :index)

      conn = get conn, Routes.aid_item_path(conn, :index)
      refute html_response(conn, 200) =~ category.name
      refute html_response(conn, 200) =~ item.name
    end

    test "renders errors when deletion is invalid", %{conn: conn, category: category} do
      item = insert(:aid_item, %{category: category})
      _entry = insert(:list_entry, %{item: item})

      conn = delete conn, Routes.aid_category_path(conn, :delete, category)
      assert redirected_to(conn) == Routes.aid_item_path(conn, :index)

      conn = get conn, Routes.aid_item_path(conn, :index)
      assert html_response(conn, 200) =~ category.name
      assert html_response(conn, 200) =~ item.name
      assert html_response(conn, 200) =~ "Categories linked to aid list entries cannot be deleted, since doing so would also destroy user-data."
    end
  end

end
