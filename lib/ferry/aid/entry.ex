defmodule Ferry.Aid.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Aid.AidList
  alias Ferry.Aid.EntryModValue
  alias Ferry.AidTaxonomy.Item

  @type t() :: %__MODULE__{}

  schema "aid__list_entries" do
    field :amount, :integer, default: 0

    belongs_to :list, AidList, foreign_key: :list_id
    belongs_to :item, Item

    has_many :mod_values, EntryModValue, foreign_key: :entry_id

    timestamps()
  end

  def create_changeset(entry, params \\ %{}) do
    entry
    |> cast(params, [:amount, :item_id, :list_id])
    # |> cast_assoc(:mod_values)
    |> validate_required([:amount])
    |> validate_number(:amount, greater_than_or_equal_to: 0)

    # Use Ecto.build_assoc to set the :list_id on create.
    |> assoc_constraint(:list)
    |> assoc_constraint(:item)
  end

  # NOTE: can't update the item, since the mods would make no sense then
  def update_changeset(entry, params \\ %{}) do
    entry
    |> cast(params, [:amount])
    # |> cast_assoc(:mod_values)
    |> validate_required([:amount])
    |> validate_number(:amount, greater_than_or_equal_to: 0)
    |> assoc_constraint(:list)
    |> assoc_constraint(:item)
  end

  def delete_changeset(entry) do
    entry
    |> cast(%{}, [])
  end

  @doc """
  Compares two entries. Returns true if both entries
  have the same item, mods and mod values
  """
  @spec eq?(t(), t()) :: true | false
  def eq?(one, another) do
    one = comparison_opts(one)
    another = comparison_opts(another)
    one == another
  end

  # Builds the structure that defines how two entries
  # are compared
  defp comparison_opts(entry) do
    [
      item: entry.item.id,
      mods: entry.item.mods |> Enum.map(&id_from/1) |> Enum.sort(),
      values:
        entry.mod_values
        |> Enum.map(fn mod_value -> mod_value.mod_value end)
        |> Enum.map(&id_from/1)
        |> Enum.sort()
    ]
  end

  defp id_from(%{id: id}), do: id

  # TODO: handle moving entries between lists in a separate changeset since that could get tricky, as the new list may have th same item w/ the same mod values already
end
