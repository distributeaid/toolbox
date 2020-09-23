defmodule Ferry.AidTaxonomy.ModValue do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.AidTaxonomy.Mod

  @type t :: %__MODULE__{}

  schema "aid__mod_values" do
    belongs_to :mod, Mod, foreign_key: :mod_id
    field :value, :string
    timestamps()
  end

  @spec changeset(
          t(),
          map()
        ) :: Ecto.Changeset.t()
  def changeset(mod_value, params \\ %{}) do
    mod_value
    |> cast(params, [:value])
    |> validate_required([:value])
    |> unique_constraint(:name,
      name: "aid__mod_values_mod_id_value_index",
      message: "already exists"
    )
  end
end
