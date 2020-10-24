defmodule Ferry.AidTest do
  use Ferry.DataCase

  import Ecto.Query, warn: false
  alias Ferry.Repo
  alias Timex

  alias Ferry.Locations
  alias Ferry.Aid
  alias Ferry.AidTaxonomy
  alias Ferry.AidTaxonomy.{Item, Mod, ModValue}
  alias Ferry.Aid.AidList
  alias Ferry.Aid.Entry
  alias Ferry.Aid.NeedsList

  # Needs List
  # ================================================================================
  # TODO: verify that list_* and get_* include entries

  describe "needs list" do
    test "get_needs_lists/3 returns all needs lists for a project that overlap a duration" do
      project = insert(:project)
      from = Timex.today() |> Timex.shift(years: -2)
      to = Timex.today() |> Timex.shift(years: 2)

      # none
      assert Aid.get_needs_lists(project, from, to) == {:ok, []}

      # 1
      list1 = insert(:needs_list, %{project: project})
      {:ok, list1} = Aid.get_needs_list(list1.id)

      assert Aid.get_needs_lists(project, from, to) == {:ok, [list1]}

      # many
      list2 = insert(:needs_list_after, %{project: project, to: list1.to})
      {:ok, list2} = Aid.get_needs_list(list2.id)
      assert Aid.get_needs_lists(project, from, to) == {:ok, [list1, list2]}

      # ordered by from date
      last_list = insert(:needs_list_after, %{project: project, to: list2.to})
      {:ok, last_list} = Aid.get_needs_list(last_list.id)

      first_list = insert(:needs_list_before, %{project: project, from: list2.from})
      {:ok, first_list} = Aid.get_needs_list(first_list.id)

      assert Aid.get_needs_lists(project, from, to) ==
               {:ok,
                [
                  first_list,
                  list1,
                  list2,
                  last_list
                ]}

      # includes lists that overlap with the duration (inclusive)
      start_overlap_list = insert(:needs_list_start_overlap, %{project: project, from: from})
      {:ok, start_overlap_list} = Aid.get_needs_list(start_overlap_list.id)

      end_overlap_list = insert(:needs_list_end_overlap, %{project: project, to: to})
      {:ok, end_overlap_list} = Aid.get_needs_list(end_overlap_list.id)

      {:ok, lists} = Aid.get_needs_lists(project, from, to)

      assert start_overlap_list in lists
      assert end_overlap_list in lists

      # doesn't include lists that fall outside the duration
      before_list = insert(:needs_list_before, %{project: project, from: from})
      {:ok, before_list} = Aid.get_needs_list(before_list.id)

      after_list = insert(:needs_list_after, %{project: project, to: to})
      {:ok, after_list} = Aid.get_needs_list(after_list.id)

      {:ok, lists} = Aid.get_needs_lists(project, from, to)
      refute Enum.any?(lists, &(&1.id == before_list.id))
      refute Enum.any?(lists, &(&1.id == after_list.id))

      # doesn't include needs lists from other projects
      other_project_list = insert(:needs_list)
      {:ok, other_project_list} = Aid.get_needs_list(other_project_list.id)
      {:ok, lists} = Aid.get_needs_lists(project, from, to)
      refute Enum.any?(lists, &(&1.id == other_project_list.id))
    end

    test "get_needs_lists/2 returns all needs lists for a project that overlap within 6 months of the given date" do
      project = insert(:project)
      # |> without_assoc(:address)
      from = Timex.today() |> Timex.shift(months: 1)
      to = from |> Timex.shift(months: 6)

      _before_list = insert(:needs_list_before, %{project: project, from: from})
      start_overlap_list = insert(:needs_list_start_overlap, %{project: project, from: from})
      {:ok, start_overlap_list} = Aid.get_needs_list(start_overlap_list.id)

      within_list =
        insert(:needs_list, %{
          project: project,
          from: from |> Timex.shift(months: 1),
          to: to |> Timex.shift(months: 2)
        })

      {:ok, within_list} = Aid.get_needs_list(within_list.id)

      end_overlap_list = insert(:needs_list_end_overlap, %{project: project, to: to})
      {:ok, end_overlap_list} = Aid.get_needs_list(end_overlap_list.id)

      _after_list = insert(:needs_list_after, %{project: project, to: to})

      assert Aid.get_needs_lists(project, from) ==
               {:ok,
                [
                  start_overlap_list,
                  within_list,
                  end_overlap_list
                ]}
    end

    test "get_needs_lists/2 returns all needs lists for a project that overlap within 6 months of today" do
      project = insert(:project)
      from = Timex.today()
      to = from |> Timex.shift(months: 6)

      _before_list = insert(:needs_list_before, %{project: project, from: from})
      start_overlap_list = insert(:needs_list_start_overlap, %{project: project, from: from})
      {:ok, start_overlap_list} = Aid.get_needs_list(start_overlap_list.id)

      within_list =
        insert(:needs_list, %{
          project: project,
          from: from |> Timex.shift(months: 1),
          to: from |> Timex.shift(months: 2)
        })

      {:ok, within_list} = Aid.get_needs_list(within_list.id)

      end_overlap_list = insert(:needs_list_end_overlap, %{project: project, to: to})
      {:ok, end_overlap_list} = Aid.get_needs_list(end_overlap_list.id)
      _after_list = insert(:needs_list_after, %{project: project, to: to})

      assert Aid.get_needs_lists(project, from) ==
               {:ok,
                [
                  start_overlap_list,
                  within_list,
                  end_overlap_list
                ]}
    end

    test "get_needs_list!/1 returns the requested needs list" do
      list = insert(:needs_list)
      {:ok, list} = Aid.get_needs_list(list.id)

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

      {:ok, list} = Aid.get_needs_list(list.id)

      assert {:ok, list} == Aid.get_needs_list(project, from)
      assert {:ok, list} == Aid.get_needs_list(project, to)

      # other project lists covering that day are ignored
      _another_list = insert(:needs_list, %{from: from, to: to})
      assert {:ok, list} == Aid.get_needs_list(project, from)

      # returns nil if there isn't a list
      assert :not_found == Aid.get_needs_list(project, ~D[1900-01-01])
    end

    test "get_current_needs_list/1 returns the project's needs list for today" do
      project = insert(:project)

      # returns nil if there isn't a list covering today
      assert :not_found == Aid.get_current_needs_list(project)

      # returns the needs list covering today
      from = Timex.today() |> Timex.shift(weeks: -1)
      to = Timex.today() |> Timex.shift(weeks: 1)
      list = insert(:needs_list, %{project: project, from: from, to: to})
      {:ok, list} = Aid.get_needs_list(list.id)
      assert {:ok, list} == Aid.get_current_needs_list(project)
      # other project lists covering today are ignored
      _another_list = insert(:needs_list, %{from: from, to: to})

      assert {:ok, list} == Aid.get_current_needs_list(project)
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

  describe "available list" do
    setup context do
      project = insert(:project)
      group = project.group

      {:ok, category} =
        AidTaxonomy.create_category(%{
          name: "test category",
          description: "test category"
        })

      {:ok, item} =
        AidTaxonomy.create_item(category, %{
          name: "test item"
        })

      {:ok, address} =
        Locations.create_address(group, %{
          label: "default",
          province: "Andalusia",
          country_code: "ES",
          postal_code: "29620",
          street: "Surinam",
          city: "Torremolinos",
          opening_hour: "08:00",
          closing_hour: "20:00",
          type: "residential",
          has_loading_equipment: false,
          has_unloading_equipment: false,
          needs_appointment: false
        })

      {:ok, available_list} = Aid.create_available_list(address)

      {:ok,
       Map.merge(context, %{
         address: address,
         item: item,
         category: category,
         group: group,
         available: available_list
       })}
    end

    test "lists available lists", %{address: address, available: available_list} do
      assert [^available_list] = Aid.get_available_lists(address)
    end

    test "deletes an available list", %{address: address, available: available_list} do
      {:ok, _} = Aid.delete_available_list(available_list)
      assert [] = Aid.get_available_lists(address)
      assert :not_found = Aid.get_available_list(available_list.id)
    end

    test "adds an entry to an available list", %{item: item, available: available_list} do
      {:ok, entry} = Aid.create_entry(available_list, item, %{amount: 1})

      assert entry.list
      assert entry.item

      assert item.id == entry.item.id
      assert available_list.id == entry.list.available_list.id

      assert [entry] == Aid.get_entries(available_list)
    end

    test "removes an entry from an available list", %{item: item, available: available_list} do
      assert {:ok, entry} = Aid.create_entry(available_list, item, %{amount: 1})

      {:ok, _} = Aid.delete_entry(entry)
      assert [] == Aid.get_entries(available_list)
    end

    test "deletes available lists event if they are not empty", %{
      item: item,
      available: available_list
    } do
      {:ok, _} = Aid.create_entry(available_list, item, %{amount: 1})
      assert 1 == Aid.count_entries()
      {:ok, _} = Aid.delete_available_list(available_list)
      assert 0 == Aid.count_entries()
    end
  end

  describe "list entries" do
    setup context do
      project = insert(:project)

      {:ok, category} =
        AidTaxonomy.create_category(%{
          name: "test category",
          description: "test category"
        })

      {:ok, item} =
        AidTaxonomy.create_item(category, %{
          name: "test item"
        })

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

    test "deleting a needs lists also deletes entries", %{item: item, needs: needs} do
      {:ok, _} = Aid.create_entry(needs, item, %{amount: 1})

      assert 1 == Aid.count_entries()

      {:ok, _} = Aid.delete_needs_list(needs)

      assert 0 == Aid.count_entries()
    end

    test "can update the amount of an entry", %{needs: needs, item: item} do
      {:ok, entry} = Aid.create_entry(needs, item, %{amount: 1})

      assert 1 == entry.amount

      {:ok, entry} = Aid.update_entry(entry, %{amount: 2})
      assert 2 == entry.amount
    end

    test "cannot update the item of an entry", %{needs: needs, item: item} do
      {:ok, entry} = Aid.create_entry(needs, item, %{amount: 1})

      item2 = insert(:aid_item)

      {:ok, _} = Aid.update_entry(entry, %{item_id: item2.id})

      {:ok, entry} = Aid.get_entry(entry.id)
      assert item == entry.item
    end
  end

  describe "list entry mod value" do
    setup context do
      project = insert(:project)

      {:ok, clothes} =
        AidTaxonomy.create_category(%{
          name: "clothes",
          description: "clothes"
        })

      {:ok, shirt} =
        AidTaxonomy.create_item(clothes, %{
          name: "shirt"
        })

      {:ok, color} =
        AidTaxonomy.create_mod(%{
          name: "color",
          type: "select",
          description: "color"
        })

      {:ok, size} =
        AidTaxonomy.create_mod(%{
          name: "size",
          type: "select",
          description: "size"
        })

      :ok = AidTaxonomy.add_mod_to_item(color, shirt)

      {:ok, red} =
        AidTaxonomy.create_mod_value(color, %{
          value: "red"
        })

      {:ok, yellow} =
        AidTaxonomy.create_mod_value(color, %{
          value: "yellow"
        })

      {:ok, regular} =
        AidTaxonomy.create_mod_value(size, %{
          value: "regular"
        })

      {:ok, large} =
        AidTaxonomy.create_mod_value(size, %{
          value: "large"
        })

      from = DateTime.utc_now()
      to = DateTime.utc_now() |> DateTime.add(24 * 3600, :second)

      {:ok, needs} = Aid.create_needs_list(project, %{from: from, to: to})

      {:ok, entry} = Aid.create_entry(needs, shirt, %{amount: 1})

      {:ok,
       Map.merge(context, %{
         shirt: shirt,
         color: color,
         clothes: clothes,
         red: red,
         yellow: yellow,
         regular: regular,
         large: large,
         needs: needs,
         entry: entry
       })}
    end

    test "can be added to an existing list entry", %{color: color, red: red, entry: entry} do
      :ok = Aid.add_mod_value_to_entry(red, entry)
      {:error, e} = Aid.add_mod_value_to_entry(red, entry)
      assert e.errors
      [mod_value: {"has too many values", _}] = e.errors

      {:ok, entry} = Aid.get_entry(entry.id)

      # Verify we can find the right mod value (red) and the right mod (color)
      # associated to the entry
      assert [mod_value] = entry.mod_values
      assert red.value == mod_value.mod_value.value
      assert color.name == mod_value.mod_value.mod.name
    end

    test "can be removed from an existing list entry", %{red: red, entry: entry} do
      {:ok, entry} = Aid.get_entry(entry.id)
      assert 0 == length(entry.mod_values)

      :ok = Aid.remove_mod_value_from_entry(red, entry)
      :ok = Aid.add_mod_value_to_entry(red, entry)

      {:ok, entry} = Aid.get_entry(entry.id)
      assert 1 == length(entry.mod_values)

      :ok = Aid.remove_mod_value_from_entry(red, entry)

      {:ok, entry} = Aid.get_entry(entry.id)
      assert 0 == length(entry.mod_values)
    end

    test "checks for allowed mod values", %{large: large, entry: entry} do
      # size is not a mod in the original shirt item so it should
      # not be allowed to add a large mod value to the entry
      {:error, e} = Aid.add_mod_value_to_entry(large, entry)
      assert e.errors
      assert [mod_value: {"must be within the entry's item mod values", _}] = e.errors
    end

    test "does not allow too many mod values", %{red: red, yellow: yellow, entry: entry} do
      :ok = Aid.add_mod_value_to_entry(red, entry)

      # If the shirt is red, since the color is a simple select, then
      # it cannot be also yellow.
      {:error, e} = Aid.add_mod_value_to_entry(yellow, entry)
      assert e.errors
      assert [mod_value: {"has too many values", _}] = e.errors
    end

    test "are deleted when the entry is deleted", %{red: red, entry: entry} do
      assert 0 == Aid.count_entry_mod_values()
      :ok = Aid.add_mod_value_to_entry(red, entry)
      assert 1 == Aid.count_entries()
      assert 1 == Aid.count_entry_mod_values()

      {:ok, _} = Aid.delete_entry(entry)
      assert 0 == Aid.count_entries()
      assert 0 == Aid.count_entry_mod_values()
      assert 4 == AidTaxonomy.count_mod_values()
    end
  end

  describe "aggregated_needs_list/2" do
    test "creates a new entry when aggregating on an empty list" do
      entries = [
        %Entry{
          item: %Item{id: "1"},
          mod_values: []
        }
      ]

      source = %NeedsList{
        entries: entries
      }

      target = %NeedsList{entries: []}

      needs = Aid.aggregated_needs_list(source, target)
      assert entries == needs.entries
    end

    test "increments amount when aggregating the same entry and mod values" do
      entries = [
        %Entry{
          amount: 1,
          item: %Item{id: "1", mods: []},
          mod_values: []
        }
      ]

      source = %NeedsList{
        entries: entries
      }

      target = %NeedsList{entries: entries}

      needs = Aid.aggregated_needs_list(source, target)
      [entry] = needs.entries
      assert 2 == entry.amount
    end

    test "is able to compare entries" do
      color = %Mod{name: "color"}

      entry_with_color = %Entry{
        amount: 1,
        item: %Item{id: "1", mods: [color]},
        mod_values: []
      }

      entry_without_color = %Entry{
        amount: 1,
        item: %Item{id: "1", mods: []},
        mod_values: []
      }

      source = %NeedsList{
        entries: [entry_with_color]
      }

      target = %NeedsList{entries: [entry_without_color]}

      needs = Aid.aggregated_needs_list(source, target)
      assert [entry_with_color, entry_without_color] == needs.entries
    end

    test "ignores the order entry mods and values" do
      color = %Mod{id: "1", name: "color"}
      size = %Mod{id: "2", name: "size"}

      red = %ModValue{id: "1", mod: color, value: "red"}
      small = %ModValue{id: "2", mod: size, value: "small"}

      entry_with_size_and_color = %Entry{
        amount: 1,
        item: %Item{id: "1", mods: [size, color]},
        mod_values: [%{mod_value: red}, %{mod_value: small}]
      }

      entry_with_color_and_size = %Entry{
        amount: 1,
        item: %Item{id: "1", mods: [color, size]},
        mod_values: [%{mod_value: small}, %{mod_value: red}]
      }

      source = %NeedsList{
        entries: [entry_with_size_and_color]
      }

      target = %NeedsList{entries: [entry_with_color_and_size]}

      needs = Aid.aggregated_needs_list(source, target)
      assert 1 = length(needs.entries)
      [entry] = needs.entries
      assert 2 == entry.amount
      assert 2 == length(entry.item.mods)
      assert 2 == length(entry.mod_values)
    end
  end

  describe "needs list by addresses" do
    setup context do
      Ferry.Fixture.NeedsListAggregation.three_entries(context)
    end

    test "aggregates common entries", %{london: london, leeds: leeds} do
      {:ok, needs} = Aid.get_current_needs_list_by_addresses([london.address, leeds.address])
      assert 3 == length(needs.entries)

      {:ok, needs} = Aid.get_current_needs_list_by_addresses([london.address])
      assert 2 == length(needs.entries)

      {:ok, needs} = Aid.get_current_needs_list_by_addresses([leeds.address])
      assert 2 == length(needs.entries)
    end
  end
end
