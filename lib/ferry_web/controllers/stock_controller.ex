defmodule FerryWeb.StockController do
  use FerryWeb, :controller

  alias Ferry.Inventory
  alias Ferry.Inventory.Stock

  def index(conn, _params) do
    stocks = Inventory.list_stocks()
    render(conn, "index.html", stocks: stocks)
  end

  def new(conn, _params) do
    changeset = Inventory.change_stock(%Stock{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"stock" => stock_params}) do
    case Inventory.create_stock(stock_params) do
      {:ok, stock} ->
        conn
        |> put_flash(:info, "Stock created successfully.")
        |> redirect(to: stock_path(conn, :show, stock))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    stock = Inventory.get_stock!(id)
    render(conn, "show.html", stock: stock)
  end

  def edit(conn, %{"id" => id}) do
    stock = Inventory.get_stock!(id)
    changeset = Inventory.change_stock(stock)
    render(conn, "edit.html", stock: stock, changeset: changeset)
  end

  def update(conn, %{"id" => id, "stock" => stock_params}) do
    stock = Inventory.get_stock!(id)

    case Inventory.update_stock(stock, stock_params) do
      {:ok, stock} ->
        conn
        |> put_flash(:info, "Stock updated successfully.")
        |> redirect(to: stock_path(conn, :show, stock))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", stock: stock, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    stock = Inventory.get_stock!(id)
    {:ok, _stock} = Inventory.delete_stock(stock)

    conn
    |> put_flash(:info, "Stock deleted successfully.")
    |> redirect(to: stock_path(conn, :index))
  end
end
