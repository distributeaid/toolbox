defmodule Ferry.Fixture.NeedsListAggregation do
  @moduledoc """
  A helper module that sets up data so that we can test
  needs list aggregations
  """

  alias Ferry.Profiles.Project
  alias Ferry.Locations
  alias Ferry.Locations.Address
  alias Ferry.Profiles
  alias Ferry.AidTaxonomy
  alias Ferry.Aid

  defp needs_setup(context) do
    {:ok, london_group} = create_group("london")

    {:ok, leeds_group} = create_group("leeds")

    {:ok, london_project} = create_project(london_group)
    {:ok, leeds_project} = create_project(leeds_group)

    {:ok, london_address} =
      Locations.create_address(london_group, %{
        label: "default",
        street: "Harp Lane",
        city: "London",
        province: "London",
        country_code: "GB",
        postal_code: "EC3R",
        opening_hour: "08:00",
        closing_hour: "20:00",
        type: "residential",
        has_loading_equipment: false,
        has_unloading_equipment: false,
        needs_appointment: false
      })

    {:ok, leeds_address} =
      Locations.create_address(leeds_group, %{
        label: "default",
        street: "Vicar Lane",
        city: "Leeds",
        province: "Leeds",
        country_code: "GB",
        postal_code: "LS17JH",
        opening_hour: "08:00",
        closing_hour: "20:00",
        type: "residential",
        has_loading_equipment: false,
        has_unloading_equipment: false,
        needs_appointment: false
      })

    {:ok, _} = Profiles.add_address_to_project(leeds_project, leeds_address)
    {:ok, _} = Profiles.add_address_to_project(london_project, london_address)

    # Reload the addresses, so that they include their relation
    # to the project
    %Address{project: %Project{}} = leeds_address = Locations.get_address(leeds_address.id)
    %Address{project: %Project{}} = london_address = Locations.get_address(london_address.id)

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
    :ok = AidTaxonomy.add_mod_to_item(size, shirt)

    {:ok, red} =
      AidTaxonomy.create_mod_value(color, %{
        value: "red"
      })

    {:ok, yellow} =
      AidTaxonomy.create_mod_value(color, %{
        value: "yellow"
      })

    {:ok, small} =
      AidTaxonomy.create_mod_value(size, %{
        value: "small"
      })

    {:ok, large} =
      AidTaxonomy.create_mod_value(size, %{
        value: "large"
      })

    from = DateTime.utc_now()
    to = DateTime.utc_now() |> DateTime.add(24 * 3600, :second)

    {:ok, needs_london} = Aid.create_needs_list(london_project, %{from: from, to: to})
    {:ok, needs_leeds} = Aid.create_needs_list(leeds_project, %{from: from, to: to})

    context =
      Map.merge(context, %{
        red: red,
        yellow: yellow,
        small: small,
        large: large,
        shirt: shirt,
        london: %{
          needs: needs_london,
          address: london_address,
          project: london_project,
          group: london_group
        },
        leeds: %{
          needs: needs_leeds,
          address: leeds_address,
          project: leeds_project,
          group: leeds_group
        }
      })

    {:ok, context}
  end

  def single_entry(context) do
    {:ok,
     %{
       shirt: shirt,
       red: red,
       large: large,
       london: london,
       leeds: leeds
     } = context} = needs_setup(context)

    {:ok, large_red_shirts_london} = Aid.create_entry(london.needs, shirt, %{amount: 4})
    :ok = Aid.add_mod_value_to_entry(large, large_red_shirts_london)
    :ok = Aid.add_mod_value_to_entry(red, large_red_shirts_london)

    {:ok, large_red_shirts_leeds} = Aid.create_entry(leeds.needs, shirt, %{amount: 4})
    :ok = Aid.add_mod_value_to_entry(large, large_red_shirts_leeds)
    :ok = Aid.add_mod_value_to_entry(red, large_red_shirts_leeds)

    {:ok, context}
  end

  def three_entries(context) do
    {:ok,
     %{
       shirt: shirt,
       red: red,
       yellow: yellow,
       large: large,
       london: london,
       leeds: leeds
     } = context} = needs_setup(context)

    {:ok, red_shirts_london} = Aid.create_entry(london.needs, shirt, %{amount: 1})
    :ok = Aid.add_mod_value_to_entry(red, red_shirts_london)

    {:ok, yellow_shirts_leeds} = Aid.create_entry(leeds.needs, shirt, %{amount: 3})
    :ok = Aid.add_mod_value_to_entry(yellow, yellow_shirts_leeds)

    {:ok, large_red_shirts_london} = Aid.create_entry(london.needs, shirt, %{amount: 4})
    :ok = Aid.add_mod_value_to_entry(large, large_red_shirts_london)
    :ok = Aid.add_mod_value_to_entry(red, large_red_shirts_london)

    {:ok, large_red_shirts_leeds} = Aid.create_entry(leeds.needs, shirt, %{amount: 4})
    :ok = Aid.add_mod_value_to_entry(large, large_red_shirts_leeds)
    :ok = Aid.add_mod_value_to_entry(red, large_red_shirts_leeds)

    {:ok, context}
  end

  defp create_group(name) do
    Profiles.create_group(%{
      name: name,
      slug: name,
      description: name,
      slack_channel_name: name,
      request_form: "https://nodomain.com/forms",
      request_form_results: "https://nodomain.com/forms",
      volunteer_form: "https://nodomain.com/forms",
      volunteer_form_results: "https://nodomain.com/forms",
      donation_form: "https://nodomain.com/forms",
      donation_form_results: "https://nodomain.com/forms"
    })
  end

  defp create_project(group) do
    Profiles.create_project(group, %{
      name: group.name,
      description: group.name
    })
  end
end
