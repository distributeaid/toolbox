defmodule FerryWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  @doc """
  Adds a validation status class to an input group.

  It seems confusing to also highlight the success fields, especially if they
  are empty.  Let's leave the "has-success" class off for now.
  """
  def validation_status_class(form, field) do
    cond do
      # Freshly loaded form.
      is_nil(form.source.action) -> ""
      Keyword.get_values(form.errors, field) |> length() > 0 -> "has-error"
      # "has-success"
      true -> ""
    end
  end

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:p, translate_error(error), class: "form-input-hint")
    end)
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext "errors", "is invalid"
    #
    #     # Translate the number of files with plural rules
    #     dngettext "errors", "1 file", "%{count} files", count
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(FerryWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(FerryWeb.Gettext, "errors", msg, opts)
    end
  end
end
