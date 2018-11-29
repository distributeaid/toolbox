defmodule FerryWeb.LinkView do
  use FerryWeb, :view

  # Links
  # ----------------------------------------------------------
  # These functions operate on a list of Links or derived data.

  def has_links?(links) do
    length(links) > 0
  end

  # Link
  # ----------------------------------------------------------
  # These functions operate on a single Link.

  def label_text(link) do
    if link.label == nil,
        do: link.url,
      else: link.label
  end

end
