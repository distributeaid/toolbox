defmodule Ferry.Repo.Migrations.RemoveAddressUniqueOwner do
  use Ecto.Migration

  def change do
    drop constraint(:addresses, :has_exactly_one_owner)
  end
end
