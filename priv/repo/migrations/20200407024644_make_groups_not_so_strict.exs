defmodule Ferry.Repo.Migrations.MakeGroupsNotSoStrict do
  use Ecto.Migration

  def change do
    alter table("groups") do
      modify :slack_channel_name, :text
      modify :description, :text

      modify :request_form, :text
      modify :volunteer_form, :text
      modify :donation_form, :text

      modify :request_form_results, :text
      modify :volunteer_form_results, :text
      modify :donation_form_results, :text
    end
  end
end
