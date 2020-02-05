defmodule Ferry.Aid.Mod do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Aid.Item

  # TODO: add boolean mods
  schema "aid__mods" do
    field :name, :string
    field :description, :string
    field :type, :string

    # used for 'select' and 'multi-select' types
    field :values, {:array, :string}

    # TODO: probably want to setup a schema for the join table with
    # has_many / belongs_to on each side, to provide flexibility if we ever need
    # metadata on the relationship
    many_to_many :items, Item, join_through: "aid__items__mods", on_replace: :delete

    # NOTE: Mods shouldn't care about ModValues, so leave out the has_many
    #       relationship to them.

    timestamps()
  end

  # TODO: do we really need two changeset functions?  can't we tell if it's an
  #       insert or update op based on a field in the changeset (i.e. if id
  #       isn't set)
  def create_changeset(mod, params \\ %{}) do
    mod
    |> cast(params, [:name, :description, :type, :values])

    |> validate_required([:name, :type])
    # TODO test error message and possibly add our own "should be %{count} character(s)"
    |> validate_length(:name, min: 2, max: 32)
    |> validate_inclusion(:type, ["integer", "select", "multi-select"])
    |> validate_values()

    |> unique_constraint(:name, message: "already exists")
  end

  def update_changeset(mod, params \\ %{}) do
    mod
    |> cast(params, [:name, :description, :type, :values])

    |> validate_required([:name, :type])
    # TODO test error message and possibly add our own "should be %{count} character(s)"
    |> validate_length(:name, min: 2, max: 32)
    |> validate_inclusion(:type, ["integer", "select", "multi-select"])
    |> validate_values()

    # additional validation on how the Mod is being changed
    |> validate_type_change()
    |> validate_values_change()

    |> foreign_key_constraint(:mod_values, name: "aid__mod_values_mod_id_fkey")
    |> unique_constraint(:name, message: "already exists")    
  end

  # TODO: force values to be unique
  #       the best place to do this may be at the top of each changeset- modifying params.values
  defp validate_values(changeset) do
    {_, type} = fetch_field(changeset, :type)

    case type do
      "integer" -> changeset |> put_change(:values, nil)
      _ ->
        changeset
        |> validate_required([:values])
        |> validate_length(:values, min: 2)
    end
  end

  # can only change type from "select" to "multi-select"
  defp validate_type_change(changeset) do
    case get_change(changeset, :type) do
      nil -> changeset
      updated_type ->
        if changeset.data.type == "select" && updated_type == "multi-select" do
          changeset
        else
          add_error(changeset, :type, "can only change type from 'select' to 'multi-select'")
        end
    end
  end

  # can only extend the list of values, not remove any
  defp validate_values_change(changeset) do
    cond do
      # Don't bother checking values if there's a type error, since the values
      # may be too screwed up to be understandable.
      Keyword.has_key?(changeset.errors, :type) -> changeset

      # Don't check values for integer mods, since they don't have values.
      get_field(changeset, :type) == "integer" -> changeset

      # Don't add an error if all the old values are included.
      # This handles cases where there is no change, since each old value will
      # be included in the list of old values.
      Enum.all?(changeset.data.values, &(&1 in get_field(changeset, :values))) ->
        changeset

      # Otherwise, we can conclude that at least 1 old value isn't included in
      # the list of new values.  Add an error.
      true -> add_error(changeset, :values, "can't remove values")
    end
  end
end
