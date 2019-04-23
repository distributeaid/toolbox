defmodule FerryWeb.StockView do
  use FerryWeb, :view

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

end
