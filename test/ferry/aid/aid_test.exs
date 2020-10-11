defmodule Ferry.AidTest do
  use Ferry.DataCase

  import Ecto.Query, warn: false
  alias Ferry.Repo
  alias Timex

  alias Ferry.Aid
  alias Ferry.Aid.AidList
  #  alias Ferry.Aid.AvailableList
  alias Ferry.Aid.Entry
  #  alias Ferry.Aid.ManifestList
  #  alias Ferry.Aid.ModValue
  alias Ferry.Aid.NeedsList

  # Needs List
  # ================================================================================
  # TODO: verify that list_* and get_* include entries

  describe "needs list" do
    test "list_needs_lists/3 returns all needs lists for a project that overlap a duration" do
      project = insert(:project)
      from = Timex.today() |> Timex.shift(years: -2)
      to = Timex.today() |> Timex.shift(years: 2)

      # none
      assert Aid.list_needs_lists(project, from, to) == []

      # 1
      list1 = insert(:needs_list, %{project: project})
      assert Aid.list_needs_lists(project, from, to) == [list1]

      # many
      list2 = insert(:needs_list_after, %{project: project, to: list1.to})
      assert Aid.list_needs_lists(project, from, to) == [list1, list2]

      # ordered by from date
      last_list = insert(:needs_list_after, %{project: project, to: list2.to})
      first_list = insert(:needs_list_before, %{project: project, from: list2.from})

      assert Aid.list_needs_lists(project, from, to) == [
               first_list,
               list1,
               list2,
               last_list
             ]

      # includes lists that overlap with the duration (inclusive)
      start_overlap_list = insert(:needs_list_start_overlap, %{project: project, from: from})
      end_overlap_list = insert(:needs_list_end_overlap, %{project: project, to: to})
      lists = Aid.list_needs_lists(project, from, to)
      assert start_overlap_list in lists
      assert end_overlap_list in lists

      # doesn't include lists that fall outside the duration
      before_list = insert(:needs_list_before, %{project: project, from: from})
      after_list = insert(:needs_list_after, %{project: project, to: to})
      lists = Aid.list_needs_lists(project, from, to)
      refute Enum.any?(lists, &(&1.id == before_list.id))
      refute Enum.any?(lists, &(&1.id == after_list.id))

      # doesn't include needs lists from other projects
      other_project_list = insert(:needs_list)
      lists = Aid.list_needs_lists(project, from, to)
      refute Enum.any?(lists, &(&1.id == other_project_list.id))
    end

    test "list_needs_lists/2 returns all needs lists for a project that overlap within 6 months of the given date" do
      project = insert(:project)
      # |> without_assoc(:address)
      from = Timex.today() |> Timex.shift(months: 1)
      to = from |> Timex.shift(months: 6)

      _before_list = insert(:needs_list_before, %{project: project, from: from})
      start_overlap_list = insert(:needs_list_start_overlap, %{project: project, from: from})

      within_list =
        insert(:needs_list, %{
          project: project,
          from: from |> Timex.shift(months: 1),
          to: to |> Timex.shift(months: 2)
        })

      end_overlap_list = insert(:needs_list_end_overlap, %{project: project, to: to})
      _after_list = insert(:needs_list_after, %{project: project, to: to})

      assert Aid.list_needs_lists(project, from) == [
               start_overlap_list,
               within_list,
               end_overlap_list
             ]
    end

    test "list_needs_lists/2 returns all needs lists for a project that overlap within 6 months of today" do
      project = insert(:project)
      from = Timex.today()
      to = from |> Timex.shift(months: 6)

      _before_list = insert(:needs_list_before, %{project: project, from: from})
      start_overlap_list = insert(:needs_list_start_overlap, %{project: project, from: from})

      within_list =
        insert(:needs_list, %{
          project: project,
          from: from |> Timex.shift(months: 1),
          to: from |> Timex.shift(months: 2)
        })

      end_overlap_list = insert(:needs_list_end_overlap, %{project: project, to: to})
      _after_list = insert(:needs_list_after, %{project: project, to: to})

      assert Aid.list_needs_lists(project, from) == [
               start_overlap_list,
               within_list,
               end_overlap_list
             ]
    end

    test "get_needs_list!/1 returns the requested needs list" do
      list = insert(:needs_list)

      assert Aid.get_needs_list!(list.id) == list
    end

    test "get_needs_list!/1 with a non-existent id throws an error" do
      assert_raise Ecto.NoResultsError,
                   ~r/^expected at least one result but got none in query/,
                   fn ->
                     Aid.get_needs_list!(1312)
                   end
    end

    test "get_needs_list/2 returns the project's needs list for the specified date" do
      project = insert(:project)
      from = ~D[1999-12-31]
      to = ~D[2000-01-01]
      list = insert(:needs_list, %{project: project, from: from, to: to})

      assert Aid.get_needs_list(project, from) == list
      assert Aid.get_needs_list(project, to) == list

      # other project lists covering that day are ignored
      _another_list = insert(:needs_list, %{from: from, to: to})
      assert Aid.get_needs_list(project, from) == list

      # returns nil if there isn't a list
      assert Aid.get_needs_list(project, ~D[1900-01-01]) == nil
    end

    test "get_current_needs_list/1 returns the project's needs list for today" do
      project = insert(:project)

      # returns nil if there isn't a list covering today
      assert Aid.get_current_needs_list(project) == nil

      # returns the needs list covering today
      from = Timex.today() |> Timex.shift(weeks: -1)
      to = Timex.today() |> Timex.shift(weeks: 1)
      list = insert(:needs_list, %{project: project, from: from, to: to})
      assert Aid.get_current_needs_list(project) == list

      # other project lists covering today are ignored
      _another_list = insert(:needs_list, %{from: from, to: to})
      assert Aid.get_current_needs_list(project) == list
    end

    test "create_needs_list/2 with valid data creates a needs list & related aid list" do
      project = insert(:project)
      attrs = params_for(:needs_list)
      assert {:ok, %NeedsList{} = needs} = Aid.create_needs_list(project, attrs)
      assert needs.from == attrs.from
      assert needs.to == attrs.to
      assert %AidList{} = needs.list

      # TODO: inject normal get preloads on successful insert? and include .list in those normal preloads?
      # assert needs.entries == []
      # assert needs.project == project
    end

    # TODO: ensure each changeset has the right errors
    test "create_needs_list/2 with invalid data returns an error changeset" do
      project = insert(:project)

      # duration
      attrs = params_for(:invalid_duration_needs_list)
      assert {:error, %Ecto.Changeset{} = _changeset} = Aid.create_needs_list(project, attrs)

      # overlap
      needs = insert(:needs_list, %{project: project})

      attrs = params_for(:needs_list_start_overlap, Map.from_struct(needs))
      assert {:error, %Ecto.Changeset{} = _changeset} = Aid.create_needs_list(project, attrs)

      attrs = params_for(:needs_list_end_overlap, Map.from_struct(needs))
      assert {:error, %Ecto.Changeset{} = _changeset} = Aid.create_needs_list(project, attrs)
    end

    test "update_needs_list/2 with valid data updates a needs list" do
      old_needs = insert(:needs_list)
      attrs = params_for(:needs_list_end_overlap, Map.from_struct(old_needs))

      assert {:ok, %NeedsList{} = needs} = Aid.update_needs_list(old_needs, attrs)
      assert needs.from == attrs.from
      assert needs.to == attrs.to

      # project & aid list (& aid list entries) shouldn't change
      assert needs.project == old_needs.project
      assert needs.list == old_needs.list
      assert needs.entries == old_needs.entries
    end

    # TODO: ensure each changeset has the right errors
    test "update_needs_list/2 with invalid data returns error changeset" do
      project = insert(:project)
      needs = insert(:needs_list, %{project: project})

      # duration
      attrs = params_for(:invalid_duration_needs_list, %{project: project})
      assert {:error, %Ecto.Changeset{} = _changeset} = Aid.update_needs_list(needs, attrs)

      # overlap
      _prev_needs = insert(:needs_list_before, %{project: project, from: needs.from})
      attrs = params_for(:needs_list_start_overlap, Map.from_struct(needs))
      assert {:error, %Ecto.Changeset{} = _changeset} = Aid.update_needs_list(needs, attrs)

      _next_needs = insert(:needs_list_after, %{project: project, to: needs.to})
      attrs = params_for(:needs_list_end_overlap, Map.from_struct(needs))
      assert {:error, %Ecto.Changeset{} = _changeset} = Aid.update_needs_list(needs, attrs)
    end

    test "delete_needs_list/1 deletes a needs list" do
      needs = insert(:needs_list)
      insert_list(3, :entry, %{list: needs.list})
      assert {:ok, %NeedsList{}} = Aid.delete_needs_list(needs)
      assert_raise Ecto.NoResultsError, fn -> Aid.get_needs_list!(needs.id) end

      # also deletes the referenced aid list & entries
      refute Repo.exists?(
               from list in AidList,
                 where: list.needs_list_id == ^needs.id
             )

      refute Repo.exists?(
               from entry in Entry,
                 join: list in assoc(entry, :list),
                 where: list.needs_list_id == ^needs.id
             )
    end
  end

  describe "list entries" do
    setup context do
      project = insert(:project)
      item = insert(:aid_item)

      from = DateTime.utc_now()
      to = DateTime.utc_now() |> DateTime.add(24 * 3600, :second)

      {:ok, needs} = Aid.create_needs_list(project, %{from: from, to: to})

      {:ok,
       Map.merge(context, %{
         item: item,
         needs: needs
       })}
    end

    test "an item can be added to a needs list as a entry", %{item: item, needs: needs} do
      {:ok, entry} = Aid.create_entry(needs, item, %{amount: 1})

      assert entry.list
      assert entry.item

      assert item.id == entry.item.id
      assert needs.id == entry.list.needs_list.id

      assert [entry] == Aid.get_entries(needs)
    end

    test "an entry can be removed from a list", %{item: item, needs: needs} do
      assert {:ok, entry} = Aid.create_entry(needs, item, %{amount: 1})

      {:ok, _} = Aid.delete_entry(entry)
      assert [] == Aid.get_entries(needs)
    end

    test "a list returns its entries too", %{item: item, needs: needs} do
      {:ok, needs} = Aid.get_needs_list(needs.id)
      assert [] == needs.entries

      {:ok, entry} = Aid.create_entry(needs, item, %{amount: 1})
      {:ok, needs} = Aid.get_needs_list(needs.id)

      assert [entry] == needs.entries
    end
  end
end
