defmodule Ferry.StartupTasks do
  def migrate do
    # Get the path to the migration files
    path = Application.app_dir(:ferry, "priv/repo/migrations")
    # Run the Ecto.Migrator
    Ecto.Migrator.run(Ferry.Repo, path, :up, all: true)
  end
end