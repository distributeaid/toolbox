defmodule Ferry.Inventory.Packaging.Photo do
  use Arc.Definition
  use Arc.Ecto.Definition

  @extension_whitelist ~w(.jpg .jpeg .gif .png)

  def __storage, do: Arc.Storage.Local

  @versions [:original, :thumb]

  # Whitelist file extensions:
  def validate({file, _}) do
    @extension_whitelist |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  def transform(:original, _) do
    {:convert, ~s(-strip -resize 512x512>)}
  end

  def transform(:thumb, _) do
    # NOTE: Thumbnails must be converted to png's due to legacy code reasons.
    #       DO NOT CHANGE THIS unless you also convert all existing thumbnails
    #       back to their original format (i.e. .jpg, etc).
    {:convert, ~s(-strip -thumbnail 128x128^ -gravity center -extent 128x128), :png}
  end

  # Override the persisted filenames:
  def filename(version, {_file, _scope}) do
    "#{version}"
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, packaging}) do
    "uploads/inventory/packaging/#{packaging.id}/"
  end

  # NOTE: We currently handle this on the frontend using FontAwesome icons.
  #
  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end
end
