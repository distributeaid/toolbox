defmodule :"Elixir.Ferry.Repo.Migrations.Adapt groups" do
  use Ecto.Migration

  def change do
    alter table("groups") do
      add :slug, :text, null: false
      add :type, :text, null: false

      add :donation_link, :text

      add :slack_channel_name, :text, null: false
      add :request_form, :text
      add :volunteer_form, :text
      add :donation_form, :text
    end
  end
end
