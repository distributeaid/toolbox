defmodule FerryWeb.LinkView do
  use FerryWeb, :view

  # Links
  # ----------------------------------------------------------
  # These functions operate on a list of Links or derived data.

  def has_links?(links) do
    length(links) > 0
  end

  def sort_links_by_category(links) do
    links_by_category = Enum.reduce(links, %{:other => []}, fn (link, sorted_links) ->
      cond do
        link.category == nil ->
          Map.put(sorted_links, :other, [link | sorted_links.other])

        Map.has_key?(sorted_links, link.category) ->
          Map.put(sorted_links, link.category, [link | sorted_links[link.category]])

        true ->
          Map.put(sorted_links, link.category, [link])
      end
    end)

    if links_by_category.other == [],
        do: Map.delete(links_by_category, :other),
      else: links_by_category
  end

  def categories(links_by_category) do
    Map.keys(links_by_category)
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
