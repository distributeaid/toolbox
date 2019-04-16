defmodule FerryWeb.ErrorView do
  use FerryWeb, :view
  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  def render("400.html", _assigns) do
    render("400_page.html", reason: "Bad Request")
  end

  def render("401.html", _assigns) do
    render("401_page.html", reason: "Not Authorized to View")
  end

  def render("403.html", _assigns) do
    render("403_page.html", reason: "Forbidden Page")
  end

  defp check_bad_ids([_, _, _, error, _]) do
    cond do
      String.contains? error, "p.id" ->
        "The project ID #{String.replace(error, ~r/[^\d]/,"")} could not be found"
      String.contains? error, "g.id" ->
        "The group ID #{String.replace(error, ~r/[^\d]/,"")} could not be found"
      true ->
        "Page Not Found"
    end
  end

  # custom 404 message
  def render("404.html", %{reason: %{message: message}}) do
    checker = String.split(message, "\n")
    cond do
      String.contains? Enum.at(checker,0), "no route found" ->
        render("404_page.html", reason: "Bad url. Check your spelling")
      String.contains? Enum.at(checker,0), "expected at least one result but got none in query" ->
        render("404_page.html", reason: check_bad_ids(checker))
      true ->
        render("404_page.html", reason: "Page Not Found")
    end
  end

  def render("500_page.html", _assigns) do
    render("500_page.html", reason: "Internal Server Error")
  end



  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
