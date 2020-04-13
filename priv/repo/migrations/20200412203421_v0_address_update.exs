defmodule Ferry.Repo.Migrations.V0AddressUpdate do
  use Ecto.Migration

  def change do

    rename table(:addresses), :country, to: :country_code
    rename table(:addresses), :state, to: :province
    rename table(:addresses), :zip_code, to: :postal_code

    alter table(:addresses) do
      modify :label, :text, from: :string, null: true
      modify :street, :text, from: :string, null: true
      modify :city, :text, from: :string, null: true

      modify :province, :text, from: :string, null: false
      modify :country_code, :text, from: :string, null: false
      modify :postal_code, :text, from: :string, null: false
    end

  end
end
