defmodule FerryWeb.AidModControllerTest do
  use FerryWeb.ConnCase

  setup do
    category = insert(:aid_category)
    items = insert_list(3, :aid_item, %{category: category})
    mod = insert(:aid_mod, %{items: items})

    conn = build_conn()
    {:ok, conn: conn, category: category, item: hd(items), mod: mod}
  end

  # Errors
  # ----------------------------------------------------------
  # TODO

  # Read
  # ------------------------------------------------------------
  
  describe "index" do
    test "lists all mods", %{conn: conn} do
      mods = insert_list(5, :aid_mod)

      conn = get conn, Routes.aid_mod_path(conn, :index)
      response = html_response(conn, 200)
      assert Enum.all?(mods, &(response =~ &1.name))
    end
  end

  # Create
  # ------------------------------------------------------------

  describe "new mod" do
    test "renders form", %{conn: conn} do
      conn = get conn, Routes.aid_mod_path(conn, :new)
      assert html_response(conn, 200) =~ "Add A New Mod"
    end
  end

  describe "create mod" do
    test "redirects to show when data is valid", %{conn: conn} do
      mod_attrs = string_params_for(:aid_mod)
      conn = post conn, Routes.aid_mod_path(conn, :create), mod: mod_attrs
      assert redirected_to(conn) == Routes.aid_mod_path(conn, :index)

      conn = get conn, Routes.aid_mod_path(conn, :index)
      assert html_response(conn, 200) =~ mod_attrs["name"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      mod_attrs = string_params_for(:invalid_aid_mod)
      conn = post conn, Routes.aid_mod_path(conn, :create), mod: mod_attrs
      assert html_response(conn, 200) =~ "Add A New Mod"
    end
  end

  # Update
  # ------------------------------------------------------------

  describe "edit mod" do
    test "renders form for editing chosen mod", %{conn: conn, mod: mod} do
      conn = get conn, Routes.aid_mod_path(conn, :edit, mod)
      html_response(conn, 200) =~ "Edit A Mod"

      # all select / multi-select values should be prepopulated on the form
      mod = insert(:aid_mod, %{type: "select"})
      conn = get conn, Routes.aid_mod_path(conn, :edit, mod)
      response = html_response(conn, 200)
      assert Enum.all?(mod.values, &(response =~ &1))
    end    
  end

  describe "update mod" do
    test "redirects when data is valid", %{conn: conn, mod: mod} do
      mod_attrs = string_params_for(:aid_mod, %{type: mod.type, values: mod.values})
      conn = put conn, Routes.aid_mod_path(conn, :update, mod), mod: mod_attrs
      assert redirected_to(conn) == Routes.aid_mod_path(conn, :index)

      conn = get conn, Routes.aid_mod_path(conn, :index)
      assert html_response(conn, 200) =~ mod_attrs["name"]
    end

    test "renders errors when data is invalid", %{conn: conn, mod: mod} do
      mod_attrs = string_params_for(:invalid_aid_mod)
      conn = put conn, Routes.aid_mod_path(conn, :update, mod), mod: mod_attrs
      assert html_response(conn, 200) =~ "Edit A Mod"
    end
  end

  # Delete
  # ------------------------------------------------------------

  describe "delete mod" do
    test "deletes chosen mod", %{conn: conn, mod: mod} do
      conn = delete conn, Routes.aid_mod_path(conn, :delete, mod)
      assert redirected_to(conn) == Routes.aid_mod_path(conn, :index)

      conn = get conn, Routes.aid_mod_path(conn, :index)
      refute html_response(conn, 200) =~ mod.name
    end

    test "renders errors when deletion is invalid", %{conn: conn, mod: mod} do
      _mod_value = insert(:mod_value, %{mod: mod})
      conn = delete conn, Routes.aid_mod_path(conn, :delete, mod)
      assert redirected_to(conn) == Routes.aid_mod_path(conn, :index)

      conn = get conn, Routes.aid_mod_path(conn, :index)
      assert html_response(conn, 200) =~ mod.name
      assert html_response(conn, 200) =~ "Aid list entries have set values for this mod, so it cannot be deleted since doing so would destroy user-data."
    end
  end

end
