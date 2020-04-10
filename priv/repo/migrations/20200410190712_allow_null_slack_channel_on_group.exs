defmodule Elixir.Ferry.Repo.Migrations.AllowNullSlackChannelOnGroup do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE groups ALTER COLUMN slack_channel_name DROP NOT NULL"
    execute "ALTER TABLE groups ALTER COLUMN request_form_results DROP NOT NULL"
    execute "ALTER TABLE groups ALTER COLUMN volunteer_form_results DROP NOT NULL"
    execute "ALTER TABLE groups ALTER COLUMN donation_form_results DROP NOT NULL"
    execute "ALTER TABLE groups ALTER COLUMN description DROP NOT NULL"
  end

  def down do
    execute "ALTER TABLE groups ALTER COLUMN slack_channel_name SET NOT NULL"
    execute "ALTER TABLE groups ALTER COLUMN request_form_results SET NOT NULL"
    execute "ALTER TABLE groups ALTER COLUMN volunteer_form_results SET NOT NULL"
    execute "ALTER TABLE groups ALTER COLUMN donation_form_results SET NOT NULL"
    execute "ALTER TABLE groups ALTER COLUMN description SET NOT NULL"
  end
end
