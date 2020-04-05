defmodule Ferry.Repo.Migrations.AdaptGroupsToFrontend2 do
  use Ecto.Migration

  def change do

    alter table("groups") do
      modify :description, :text, null: false

      modify :request_form, :text, null: false
      modify :volunteer_form, :text, null: false
      modify :donation_form, :text, null: false

      add :request_form_results, :text, null: false
      add :volunteer_form_results, :text, null: false
      add :donation_form_results, :text, null: false

    end

  end
end
