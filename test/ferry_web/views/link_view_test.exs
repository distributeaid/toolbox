defmodule FerryWeb.LinkViewTest do
  use FerryWeb.ConnCase, async: true

  alias FerryWeb.LinkView

  # Data & Helpers
  # ----------------------------------------------------------

  @min_link %{
    label: nil,
    url: "https://johnnypanichiphop.bandcamp.com/album/voidspit"
  }

  @typical_link %{
    label: "Sima Lee",
    url: "https://simalee.bandcamp.com/album/trap-liberation-army"
  }

  # @typical_link_2 %{
  #   label: "Lee Reed",
  #   url: "https://htsn.bandcamp.com/album/the-steal-city-ep"
  # }

  # @typical_link_3 %{
  #   label: "Toni Zamboni",
  #   url: "https://tonyzamboni.bandcamp.com/album/zamboni-world-ep"
  # }

  # Links
  # ----------------------------------------------------------

  test "has_links/1 determines if there are links or not" do
    links = []
    refute LinkView.has_links? links

    links = [@min_link]
    assert LinkView.has_links? links
  end

  # Link
  # ----------------------------------------------------------
  test "label_text/1 produces an appropriate label" do
    assert "Sima Lee" == LinkView.label_text(@typical_link)
    assert "https://johnnypanichiphop.bandcamp.com/album/voidspit" == LinkView.label_text(@min_link)
  end

end
