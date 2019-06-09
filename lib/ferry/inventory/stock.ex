defmodule Ferry.Inventory.Stock do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Profiles.Project
  alias Ferry.Inventory.{Item, Mod, Packaging}
  alias Ferry.Inventory.Stock.Photo

  schema "inventory_stocks" do
    field :have, :integer
    field :need, :integer
    field :unit, :string
    field :description, :string
    field :photo, Photo.Type

    belongs_to :project, Project
    belongs_to :item, Item, on_replace: :nilify
    belongs_to :mod, Mod, on_replace: :nilify
    belongs_to :packaging, Packaging, on_replace: :update

    timestamps()
  end

  @doc false
  def changeset(stock, attrs) do
    stock
    |> cast(attrs, [:project_id, :have, :need, :unit, :description])
    |> validate_required([:project_id, :have, :need, :unit])
    |> validate_number(:have, greater_than_or_equal_to: 0)
    |> validate_number(:need, greater_than_or_equal_to: 0)

    |> cast_assoc(:packaging)
    |> put_assoc(:item, attrs["item"])
    |> put_assoc(:mod, attrs["mod"])

    |> assoc_constraint(:project)
    |> assoc_constraint(:item)
    |> assoc_constraint(:mod)
    |> assoc_constraint(:packaging)
  end

  @doc false
  def validate(stock, attrs \\ %{}) do
    stock
    |> cast(attrs, [:have, :need, :unit, :description])
    |> validate_required([:have, :need, :unit])
    |> validate_number(:have, greater_than_or_equal_to: 0)
    |> validate_number(:need, greater_than_or_equal_to: 0)

    |> assoc_constraint(:project)
    |> assoc_constraint(:item)
    |> assoc_constraint(:mod)
    |> assoc_constraint(:packaging)
  end

  @doc false
  def image_changeset(stock, attrs) do
    stock
    |> cast_attachments(attrs, [:photo])
  end
end
