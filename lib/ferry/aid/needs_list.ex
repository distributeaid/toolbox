defmodule Ferry.Aid.NeedsList do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{}

  alias Ferry.Aid.AidList
  alias Ferry.Profiles.Project

  schema "aid__needs_lists" do
    field :from, :date
    field :to, :date

    belongs_to :project, Project

    has_one :list, AidList

    # shortcut / enables polymorphic lists
    has_many :entries, through: [:list, :entries]

    timestamps()
  end

  def changeset(needs_list, params \\ %{}, has_overlap?) when is_function(has_overlap?, 1) do
    needs_list
    |> cast(params, [:from, :to])
    |> validate_required([:from, :to])
    |> validate_duration()

    # use Ecto.build_assoc when creating a NeedsList to satisfy this
    |> assoc_constraint(:project)
    |> maybe_check_overlap(has_overlap?)
  end

  # There's already an error. Skip this check, since calling `has_overlap?`
  # with a bad data doesn't make sense, and it's an expensive check.
  defp maybe_check_overlap(%{errors: errors} = changeset, _has_overlap?)
       when length(errors) > 0 do
    changeset
  end

  defp maybe_check_overlap(changeset, has_overlap?) do
    needs = apply_changes(changeset)

    if has_overlap?.(needs) do
      # TODO: actually get overlapping lists and include them in error, to show more info / link to them on the frontend? overkill for now since monthly lists will be enforced by the UI / controller
      #       add_error(changeset, :overlap, "needs lists for the same project cannot overlap dates", overlapping_lists: overlapping_lists)
      add_error(changeset, :overlap, "needs lists for the same project cannot overlap dates")
    else
      changeset
    end
  end

  # TODO: validate that :to is in the future (and possibly by a certain amount)?
  defp validate_duration(changeset) do
    from = get_field(changeset, :from)
    to = get_field(changeset, :to)

    cond do
      # invalid - changeset already has an error from validate_required
      is_nil(from) or is_nil(to) -> changeset
      # valid
      # TODO: enforce a minimum range > 1?
      Date.diff(to, from) > 0 -> changeset
      # invalid
      true -> add_error(changeset, :to, "must be later than From")
    end
  end
end
