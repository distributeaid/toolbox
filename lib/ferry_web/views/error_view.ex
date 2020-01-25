defmodule FerryWeb.ErrorView do
  use FerryWeb, :view

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end

  def render("400.html", _assigns) do
    render("error_page.html", error: "400", reason: "Bad Request")
  end

  def render("401.html", _assigns) do
    render("error_page.html", error: "401", reason: "Not Authorized to View")
  end

  def render("403.html", _assigns) do
    render("error_page.html", error: "403", reason: "Forbidden Page")
  end

  def render("404.html", %{reason: %{message: message}}) do
    checker = String.split(message, "\n")
    error = "404"
    cond do
      String.contains? Enum.at(checker, 0), "no route found" ->
        render("error_page.html", error: error, reason: "Bad url. Check your spelling")
      String.contains? Enum.at(checker, 0), "expected at least one result but got none in query" ->
        render("error_page.html", error: error, reason: check_bad_ids(checker))
      true ->
        render("error_page.html", error: error, reason: "Page Not Found")
    end
  end

  def render("500.html", _assigns) do
    render("error_page.html", error: "500", reason: "Internal Server Error")
  end

  defp check_bad_ids([_, _, _, error, address_error | _tail]) do
    cond do
      String.contains? error, "p.id" ->
        "The Project ID #{String.replace(error, ~r/[^\d]/,"")} Could Not be Found"
      String.contains? error, "g.id" ->
        "The Group ID #{String.replace(error, ~r/[^\d]/,"")} Could Not be Found"
      String.contains? error, "l.id" ->
        "Link ID #{String.replace(error, ~r/[^\d]/,"")} Could Not be Found"
      String.contains? address_error, "a.id" ->
        "Address #{String.replace(address_error, ~r/[^\d]/,"")} Could Not be Found"
      true ->
        "Page Not Found"
    end
  end

end
