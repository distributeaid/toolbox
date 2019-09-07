defmodule FerryWeb.RoleController do
  use FerryWeb, :controller

  alias Ferry.Profiles
  alias Ferry.Shipments
  alias Ferry.Shipments.Role

  # Role Controller
  # ==============================================================================

  # Helpers
  # ----------------------------------------------------------

  # TODO: copied from group_controller, refactor into shared function or something
  defp current_group(_conn = %{assigns: %{current_user: %{group_id: group_id}}}) do
    Profiles.get_group!(group_id)
  end

  defp current_group(_conn) do
    nil
  end

  # Create
  # ----------------------------------------------------------

  def new(conn, %{"group_id" => group_id, "shipment_id" => shipment_id}) do
    groups = Profiles.list_groups()
    group = Profiles.get_group!(group_id)
    shipment = Shipments.get_shipment!(shipment_id)
    changeset = Shipments.change_role(%Role{
      group_id: nil,
      shipment_id: shipment.id
    })

    render(conn, "new.html", current_group: current_group(conn), group: group, shipment: shipment, groups: groups, changeset: changeset)
  end

  def create(conn, %{"group_id" => group_id, "shipment_id" => shipment_id, "role" => role_params}) do
    group = Profiles.get_group!(group_id)
    shipment = Shipments.get_shipment!(shipment_id)

    role_params = Map.put(role_params, "shipment_id", shipment_id)

    case Shipments.create_role(role_params) do
      {:ok, _role} ->
        conn
        |> put_flash(:info, "Role created successfully.")
        |> redirect(to: Routes.group_shipment_path(conn, :show, group, shipment))
      {:error, %Ecto.Changeset{} = changeset} ->
        groups = Profiles.list_groups()
        render(conn, "new.html", current_group: current_group(conn), group: group, shipment: shipment, groups: groups, changeset: changeset)
    end
  end

  # Update
  # ----------------------------------------------------------

  def edit(conn, %{"group_id" => group_id, "shipment_id" => shipment_id, "id" => id}) do
    group = Profiles.get_group!(group_id)
    shipment = Shipments.get_shipment!(shipment_id)
    role = Shipments.get_role!(id)
    changeset = Shipments.change_role(role)

    render(conn, "edit.html", current_group: current_group(conn), group: group, shipment: shipment, role: role, changeset: changeset)
  end

  def update(conn, %{"group_id" => group_id, "shipment_id" => shipment_id, "id" => id, "role" => role_params}) do
    group = Profiles.get_group!(group_id)
    shipment = Shipments.get_shipment!(shipment_id)
    role = Shipments.get_role!(id)

    case Shipments.update_role(role, role_params) do
      {:ok, _role} ->
        conn
        |> put_flash(:info, "Role updated successfully.")
        |> redirect(to: Routes.group_shipment_path(conn, :show, group, shipment))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", current_group: current_group(conn), group: group, shipment: shipment, role: role, changeset: changeset)
    end
  end

  # Delete
  # ----------------------------------------------------------

  def delete(conn, %{"group_id" => group_id, "shipment_id" => shipment_id, "id" => id}) do
    group = Profiles.get_group!(group_id)
    shipment = Shipments.get_shipment!(shipment_id)
    role = Shipments.get_role!(id)

    case Shipments.delete_role(role) do
      {:ok, _role} ->
        conn
        |> put_flash(:info, "Role deleted successfully.")
        |> redirect(to: Routes.group_shipment_path(conn, :show, group, shipment))
        
      {:error, %Ecto.Changeset{} = changeset} ->
        error_msg = Keyword.get(changeset.errors, :shipment) |> elem(0)
        conn
        |> put_flash(:error, error_msg)
        |> redirect(to: Routes.group_shipment_path(conn, :show, group, shipment))
    end
  end
end
