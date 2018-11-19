defmodule FerryWeb.AddressController do
  use FerryWeb, :controller

  alias Ferry.Profiles
  alias Ferry.Locations
  alias Ferry.Locations.Address

  # Address Controller
  # ==============================================================================

  # Show
  # ----------------------------------------------------------

  def index(conn, %{"group_id" => group_id}) do
    group = Profiles.get_group!(group_id)
    addresses = Locations.list_addresses(group)
    render(conn, "index.html", group: group, addresses: addresses)
  end

  def show(conn, %{"group_id" => group_id, "id" => id}) do
    group = Profiles.get_group!(group_id)
    address = Locations.get_address!(id)
    render(conn, "show.html", group: group, address: address)
  end

  # Create
  # ----------------------------------------------------------

  def new(conn, %{"group_id" => group_id}) do
    group = Profiles.get_group!(group_id)
    changeset = Locations.change_address(%Address{})
    render(conn, "new.html", group: group, changeset: changeset)
  end

  def create(conn, %{"group_id" => group_id, "address" => address_params}) do
    group = Profiles.get_group!(group_id)

    case Locations.create_address(group, address_params) do
      {:ok, address} ->
        conn
        |> put_flash(:info, "Address created successfully.")
        |> redirect(to: group_address_path(conn, :show, group, address))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", group: group, changeset: changeset)
    end
  end

  # Update
  # ----------------------------------------------------------

  def edit(conn, %{"group_id" => group_id, "id" => id}) do
    group = Profiles.get_group!(group_id)
    address = Locations.get_address!(id)
    changeset = Locations.change_address(address)
    render(conn, "edit.html", group: group, address: address, changeset: changeset)
  end

  def update(conn, %{"group_id" => group_id, "id" => id, "address" => address_params}) do
    group = Profiles.get_group!(group_id)
    address = Locations.get_address!(id)

    case Locations.update_address(address, address_params) do
      {:ok, address} ->
        conn
        |> put_flash(:info, "Address updated successfully.")
        |> redirect(to: group_address_path(conn, :show, group, address))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", group: group, address: address, changeset: changeset)
    end
  end

  # Delete
  # ----------------------------------------------------------

  def delete(conn, %{"group_id" => group_id, "id" => id}) do
    group = Profiles.get_group!(group_id)
    address = Locations.get_address!(id)
    {:ok, _address} = Locations.delete_address(address)

    conn
    |> put_flash(:info, "Address deleted successfully.")
    |> redirect(to: group_address_path(conn, :index, group))
  end
end