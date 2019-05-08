defmodule FerryWeb.StockView do
  use FerryWeb, :view

  alias Ferry.Inventory.Stock.Photo

  def has_stocks?(stocks) do
    length(stocks) > 0
  end

  def list_projects(projects) do
    Enum.map(projects, fn project ->
      {project.name, project.id}
    end)
  end

  def print_gender(gender) do
    case gender do
      "masc" -> "male"
      "fem" -> "female"
      _ -> ""
    end
  end

  def list_genders do
    ["---": nil, "Male": "masc", "Female": "fem"]
  end

  def list_ages do
    ["---": nil, "Adult": "adult", "Child": "child", "Baby": "baby"]
  end

  def list_sizes do
    ["---": nil, "Small": "small", "Medium": "medium", "Large": "large", "Extra Large": "x-large"]
  end

  def list_seasons do
    ["---": nil, "Summer": "summer", "Winter": "winter"]
  end

  def stock_photo(stock) do
    alt_text = "Example of #{stock.item.name} (#{stock.item.category.name})"
    url = Photo.url({stock.photo, stock}, :original)
    img_tag url, alt: alt_text
  end

  # duck typing- works for categories & models since they both have id / name fields
  def selectify(names_list) do
    names_list
    |> Enum.map(fn %{name: name} ->
      name
    end)
    |> Enum.sort()
  end

end
