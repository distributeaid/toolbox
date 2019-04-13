defmodule FerryWeb.ErrorView do
  use FerryWeb, :view
  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  # explicit check for bad group id as opposed to other 404 errors
  defp check_bad_group_id([views,groups | tail]) when tail != [] do
    [id | tail] = tail
    if views=="public" and groups=="groups" and Integer.parse(id) != :error do
      {:ok, "A group with the ID #{id} does not exist"}
    else
      {:error, "Page Not Found"}
    end
  end

  # function stubbed out for now, but will allow us to expand 404 error messages as we see fit
  defp check_bad_group_id(_path) do
    {:error, "Page Not Found"}
  end

  # custom 404 message
  def render("404.html", %{conn: %{path_info: path }}) do
    case check_bad_group_id(path) do
      {:ok, id} ->
        id
      {:error, reason} ->
        reason
    end
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
