defmodule Ferry.Inventory.Stock do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Profiles.Project
  alias Ferry.Inventory.{Item, Mod, Packaging}
  alias Ferry.Inventory.Stock.Photo

  schema "inventory_stocks" do
    field :have, :integer, default: 0
    field :need, :integer, default: 0
    field :available, :integer, default: 0
    field :unit, :string, default: "Items"
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
    |> cast(attrs, [:project_id, :have, :need, :available, :unit, :description])
    |> validate_required([:project_id, :have, :need, :available, :unit])
    |> validate_number(:have, greater_than_or_equal_to: 0)
    |> validate_number(:need, greater_than_or_equal_to: 0)
    |> validate_available()

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
    |> cast(attrs, [:have, :available, :need, :unit, :description])
    |> validate_required([:have, :need, :unit])
    |> validate_number(:have, greater_than_or_equal_to: 0)
    |> validate_number(:need, greater_than_or_equal_to: 0)
    |> validate_available()

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

  defp validate_available(changeset) do
    {_, have} = changeset |> fetch_field(:have)
    {_, available} = changeset |> fetch_field(:available)
    {_, need} = changeset |> fetch_field(:need)

    changeset = changeset
    |> validate_number(:available, greater_than_or_equal_to: 0)
    |> validate_number(:available, less_than_or_equal_to: have,
      message: "You cannot list more available items than you currently have."
    )

    if available > 0 and need > 0 do
      changeset |> add_error(:available, "You cannot list available items if you need more of them.")
    else
      changeset
    end
  end
end
