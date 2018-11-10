defmodule FerryWeb.LinkViewTest do
  use FerryWeb.ConnCase, async: true

  alias FerryWeb.LinkView

  # Data & Helpers
  # ----------------------------------------------------------

  @min_link %{
    category: nil,
    label: nil,
    url: "https://johnnypanichiphop.bandcamp.com/album/voidspit"
  }

  @typical_link %{
    category: "Rap",
    label: "Sima Lee",
    url: "https://simalee.bandcamp.com/album/trap-liberation-army"
  }

  @typical_link_2 %{
    category: "Rap",
    label: "Lee Reed",
    url: "https://htsn.bandcamp.com/album/the-steal-city-ep"
  }

  @typical_link_3 %{
    category: "Chill",
    label: "Toni Zamboni",
    url: "https://tonyzamboni.bandcamp.com/album/zamboni-world-ep"
  }

  # Links
  # ----------------------------------------------------------

  test "has_links/1 determines if there are links or not" do
    links = []
    refute LinkView.has_links? links

    links = [@min_link]
    assert LinkView.has_links? links
  end

  test "sort_links_by_category/1 organizes links by category" do
    assert %{} == LinkView.sort_links_by_category([])

    assert %{other: [@min_link]} == LinkView.sort_links_by_category([@min_link])

    assert %{"Rap" => [@typical_link]} == LinkView.sort_links_by_category([@typical_link])

    assert %{:other => [@min_link], "Rap" => [@typical_link_2, @typical_link], "Chill" => [@typical_link_3]}
      == LinkView.sort_links_by_category([@min_link, @typical_link, @typical_link_2, @typical_link_3])
  end

  test "categories/1 lists the categories of links" do
    assert [] = LinkView.categories(%{})

    assert [:other] = LinkView.categories(%{other: [@min_link]})

    assert ["Rap"] == LinkView.categories(%{"Rap" => [@typical_link]})

    assert [:other, "Chill", "Rap"]
      == LinkView.categories(%{:other => [@min_link], "Rap" => [@typical_link_2, @typical_link], "Chill" => [@typical_link_3]})
  end

  # Link
  # ----------------------------------------------------------
  test "label_text/1 produces an appropriate label" do
    assert "Sima Lee" == LinkView.label_text(@typical_link)
    assert "https://johnnypanichiphop.bandcamp.com/album/voidspit" == LinkView.label_text(@min_link)
  end

end
