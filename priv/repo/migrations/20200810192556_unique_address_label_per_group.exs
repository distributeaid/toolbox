defmodule Ferry.Repo.Migrations.UniqueAddressLabelPerGroup do
  use Ecto.Migration

  def change do
    create unique_index(:addresses, [:group_id, :label], name: :unique_address_label_per_group)
  end
end
