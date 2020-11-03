defmodule Ferry.AidTaxonomy.Mod do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.AidTaxonomy.ModValue
  alias Ferry.Utils

  @type t :: %__MODULE__{}

  # TODO: add boolean mods
  schema "aid__mods" do
    field :name, :string
    field :description, :string
    field :type, :string
    field :slug, :string

    has_many :values, ModValue, foreign_key: :mod_id

    timestamps()
  end

  # TODO: do we really need two changeset functions?  can't we tell if it's an
  #       insert or update op based on a field in the changeset (i.e. if id
  #       isn't set)
  def create_changeset(mod, params \\ %{}) do
    mod
    |> cast(params, [:name, :description, :type])
    |> validate_required([:name, :type, :description])
    # TODO test error message and possibly add our own "should be %{count} character(s)"
    |> validate_length(:name, min: 2, max: 32)
    |> validate_length(:description, min: 2, max: 32)
    |> validate_inclusion(:type, ["integer", "select", "multi-select"])
    # |> validate_values()
    |> unique_constraint(:name, message: "already exists")
    |> Utils.put_slug()
    |> unique_constraint(:slug)
  end

  def update_changeset(mod, params \\ %{}) do
    mod
    |> cast(params, [:name, :description, :type])
    |> validate_required([:name, :type])
    # TODO test error message and possibly add our own "should be %{count} character(s)"
    |> validate_length(:name, min: 2, max: 32)
    |> validate_inclusion(:type, ["integer", "select", "multi-select"])
    # additional validation on how the Mod is being changed
    |> unique_constraint(:name, message: "already exists")
    |> Utils.put_slug()
    |> unique_constraint(:slug)
  end

  def delete_changeset(mod, params \\ %{}) do
    mod
    |> update_changeset(params)
    |> foreign_key_constraint(:id,
      name: :aid__mod_values_mod_id_fkey,
      message: "has mod values"
    )
    |> foreign_key_constraint(:id,
      name: :aid__items__mods_mod_id_fkey,
      message: "has items"
    )
  end
end
