defmodule Ferry.Utils do
  import Ecto.Changeset

  def slugify(input) do
    input
    |> String.downcase()
    |> String.replace(~r/[^a-zA-Z0-9]+/, "_")
  end

  def put_normalized_name(%Ecto.Changeset{valid?: true} = changeset) do
    name = get_field(changeset, :name)
    put_change(changeset, :normalized_name, slugify(name))
  end

  def put_normalized_name(changeset) do
    changeset
  end
end
