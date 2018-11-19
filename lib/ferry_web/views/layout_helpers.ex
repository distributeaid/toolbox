defmodule FerryWeb.LayoutHelpers do
  def page_background_img_class(_conn = %{request_path: request_path}) do
    cond do
      String.match?(request_path, ~r/^\/public\/addresses/u) ->
        "page-content--addresses"

      String.match?(request_path, ~r/^\/public\/groups\/[\d]+\/projects/u) ->
        "page-content--projects"
      String.match?(request_path, ~r/^\/public\/projects/u) ->
        "page-content--projects"
      String.match?(request_path, ~r/^\/groups\/[\d]+\/projects/u) ->
        "page-content--projects"

      String.match?(request_path, ~r/^\/public\/groups/u) ->
        "page-content--groups"
      String.match?(request_path, ~r/^\/groups/u) ->
        "page-content--groups"

      String.match?(request_path, ~r/^\/public\/session/u) ->
        "page-content--session"

      String.match?(request_path, ~r/^\//u) ->
        "page-content--welcome"
      true ->
        "page-content--welcome" # always show a background image
                                # TODO: pick a distinct default one
    end
  end
end