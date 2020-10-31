defmodule Ferry.Utils do
  import Ecto.Changeset

  @doc """
  Create url safe parameter that can be used to lookup item from database

  ## Example

      iex> Ferry.Utils.slugify("This is some, Text 123!")
      "this-is-some-text-123-"
  """

  def slugify(input) do
    input
    |> String.downcase()
    |> String.replace(~r/[^a-zA-Z0-9]+/, "-")
  end

  def put_slug(%Ecto.Changeset{valid?: true} = changeset) do
    name = get_field(changeset, :name)
    put_change(changeset, :slug, slugify(name))
  end

  def put_slug(changeset) do
    changeset
  end
end
