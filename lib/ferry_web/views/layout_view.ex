defmodule FerryWeb.LayoutView do
  use FerryWeb, :view

  def chat_jwt(nil) do
    ""
  end

  def chat_jwt(token) do
    ~E(
      <!-- Chat -->
      <meta name="chat:jwt" content="<%= token %>">
    )
  end
end
