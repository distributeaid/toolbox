defmodule Ferry.Profiles.Group.Logo do
  use Arc.Definition
  use Arc.Ecto.Definition

  @extension_whitelist ~w(.jpg .jpeg .gif .png)

  def __storage, do: Arc.Storage.Local # Add this

  # Include ecto support (requires package arc_ecto installed):
  # use Arc.Ecto.Definition

  @versions [:original]

  # To add a thumbnail version:
  @versions [:original, :thumb]

  # Override the bucket on a per definition basis:
  # def bucket do
  #   :custom_bucket_name
  # end

  # Whitelist file extensions:
  def validate({file, _}) do
    @extension_whitelist |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  def transform(:original, _) do
    {:convert, ~s(-strip -resize 256x256^ -gravity center -extent 256x256)}
  end

  def transform(:thumb, _) do
    # NOTE: Thumbnails must be converted to png's due to legacy code reasons.
    #       DO NOT CHANGE THIS unless you also convert all existing thumbnails
    #       back to their original format (i.e. .jpg, etc).
    {:convert, ~s(-strip -thumbnail 128x128^ -gravity center -extent 128x128), :png}
  end

  # Override the persisted filenames:
  def filename(version, _) do
    "logo_#{version}"
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, scope}) do
    "uploads/groups/#{scope.id}/logo/"
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: MIME.from_path(file.file_name)]
  # end
end
