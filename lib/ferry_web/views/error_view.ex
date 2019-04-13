defmodule FerryWeb.ErrorView do
  use FerryWeb, :view
  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  defp check_bad_group_id([views,groups | tail]) when tail != [] do
    [id | tail] = tail
    cond do
      views=="public" and groups=="groups" and Integer.parse(id) != :error ->
        true
      true ->
        false
    end
  end

  defp check_bad_group_id(_path) do
    false
  end

  def render("404.html", %{conn: %{path_info: path }}) do
    
    case check_bad_group_id(path) do
      true ->
        "A group with the ID #{Enum.at(path,2)} does not exist"
      false ->
        "Page not Found"
    end
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
