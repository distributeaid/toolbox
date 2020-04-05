defmodule Ferry.Factory do
  @moduledoc """
    Provides factory function for tests.

    Inspired by: https://github.com/digitalnatives/course_planner/blob/7c5017ffb6c1f068691c6e6f1a17dce10ba3f839/test/support/factory.ex
  """

  use ExMachina.Ecto, repo: Ferry.Repo

  alias Timex

  # To prevent conflicts between the new AidTaxonomy context and the old Inventory
  # context, the following modules will be referred to by their full namespaces.
  # Similarly, their factory functions (and related helpers) have been prefixed
  # with `aid_` to prevent conflicts with the inventory factory functions.
  #
  #   - Ferry.AidTaxonomy.Category // aid_category_factory
  #   - Ferry.AidTaxonomy.Item     // aid_item_factory
  #   - Ferry.AidTaxonomy.Mod      // aid_mod_factory
  alias Ferry.{
    Accounts.User,
    Aid.AidList,
    Aid.AvailableList,
    Aid.Entry,
    Aid.ManifestList,
    Aid.ModValue,
    Aid.NeedsList,
    # See note above the alias statement.
    # AidTaxonomy.Category,
    # AidTaxonomy.Item
    # AidTaxonomy.Mod,
    Inventory.Category,
    Inventory.Item,
    Inventory.Mod,
    Inventory.Packaging,
    Inventory.Stock,
    Links.Link,
    Locations.Address,
    Locations.Geocode,
    Profiles.Group,
    Profiles.Project,
    Shipments.Shipment,
    Shipments.Role,
    Shipments.Route
  }

  @long_text String.duplicate("x", 256)
  @long_email String.duplicate("x", 244) <> "@example.com"

  # NOTE: @password must be the same in `conn_case.ex`
  @password "lasdjkf o827349081247SLKDJFSD87634784¡¨ˆ™˙´¨¥∂œ•ª¨∂"
  @password_hash User.encrypt_password(@password)

  # Helpers
  # ------------------------------------------------------------
  
  # Partly based on: https://stackoverflow.com/questions/49996642/ecto-remove-preload/49997873#49997873
  def without_assoc(data, access, cardinality \\ :one)

  def without_assoc(list, path, cardinality) when is_list(list) and is_list(path) do
    field = List.last(path)

    path = Enum.map(path, fn step ->
      Access.key(step)
    end)

    # assumes all structs in the list are the same type
    owner = case length(path) do
      # owner is just an entry in the list
      1 -> hd(list)

      # follow the path to the n-1 step to find the field's owner
      _ -> get_in(hd(list), List.pop_at(path, -1) |> elem(1))
    end

    not_loaded = %Ecto.Association.NotLoaded{
      __field__: field,
      __owner__: owner.__struct__,
      __cardinality__: cardinality
    }

    Enum.map(list, fn struct ->
      put_in(struct, path, not_loaded)
    end)
  end

  def without_assoc(list, field, cardinality) when is_list(list) do
    without_assoc(list, [field], cardinality)
  end

  def without_assoc(%{} = struct, path, cardinality) when is_list(path) do
    without_assoc([struct], path, cardinality) |> hd()
  end

  def without_assoc(%{} = struct, field, cardinality) do
    without_assoc([struct], [field], cardinality) |> hd()
  end

  def string_keys_to_atoms(string_key_map) when is_map(string_key_map) do
    for {key, val} <- string_key_map,
      into: %{},
      do: {String.to_atom(key), val}
  end

  def atom_keys_to_strings(atom_key_map) when is_map(atom_key_map) do
    for {key, val} <- Map.to_list(atom_key_map),
      into: %{},
      do: {Atom.to_string(key), val}
  end


  # ExMachina Factories
  # ==============================================================================
  # TODO: split up into model-specific files
  #       https://hexdocs.pm/ex_machina/readme.html#splitting-factories-into-separate-files

  # Group
  # ----------------------------------------------------------

  def group_factory do
    %Group{
      name: sequence("Food Clothing and Resistance Collective"),
      slug: sequence("food-clothing-and-resistance-collective"),
      description: "We show solidarity with our neighbors by using mutual aid to collect food and clothing from the community and distribute it to those in need.",

      # add other group types here
      type: sequence(:group_type, ["M4D_CHAPTER"]),

      slack_channel_name: "FCRC is on IRC Baby #cool"
    }
  end

  def invalid_group_factory do
    struct!(
      group_factory(),
      %{
        name: ""
      }
    )
  end

  def with_project(%Group{} = group) do
    project = insert(:project, group: group)

    if is_list(group.projects) do
      %{group | projects: [project | group.projects]}
    else
      %{group | projects: [project]}
    end
  end

  # User
  # ----------------------------------------------------------

  def user_factory do
    %User{
      email: sequence(:email, &"huey.p-#{&1}@example.org"),
      password_hash: @password_hash
    }
  end

  def invalid_user_factory do
    struct!(
      user_factory(),
      %{
        email: ""
      }
    )
  end

  def invalid_long_user_factory do
    struct!(
      user_factory(),
      %{
        email: @long_email
      }
    )
  end

  def new_user_factory do
    struct!(
      user_factory(),
      %{
        password_hash: nil,
        password: @password
      }
    )
  end

  # Project
  # ----------------------------------------------------------

  def project_factory do
    %Project{
      name: sequence("Klimb"),
      description: "Up and over their walls!  Snip-snip the barbed wire with some handy dandy bolt cutters.",

      group: build(:group),
      address: build(:address, geocode: build(:geocode))
    }
  end

  def min_project_factory do
    struct!(
      project_factory(),
      %{
        description: nil
      }
    )
  end

  def invalid_project_factory do
    struct!(
      project_factory(),
      %{
        name: ""
      }
    )
  end

  # Link
  # ----------------------------------------------------------

  def link_factory do
    %Link{
      label: sequence("Are You Syrious?"),
      url: sequence(:url, &"https://medium.com/@AreYouSyrious?fakeParam=#{&1}")
    }
  end

  def invalid_link_factory do
    struct!(
      link_factory(),
      %{
        url: ""
      }
    )
  end

  # Address
  # ----------------------------------------------------------
  def address_factory do
    %Address{
      label: sequence("Where I Want To Move"),
      street: sequence(:street, &"161#{&1} Exarchia Avenue"),
      city: "Athens",
      state: "Attica",
      country: "Greece",
      zip_code: "106 81"
    }
  end

  def min_address_factory do
    struct!(
      address_factory(),
      %{
        street: nil,
        state: nil,
        zip_code: nil
      }
    )
  end

  def invalid_address_factory(attrs \\ %{}) do
    build(:invalid_short_address, attrs)
  end

  def invalid_nil_address_factory do
    struct!(
      address_factory(),
      %{
        label: nil,
        city: nil,
        country: nil
      }
    )
  end

  def invalid_short_address_factory do
    struct!(
      address_factory(),
      %{
        label: "",
        city: "",
        country: "1"
      }
    )
  end

  def invalid_long_address_factory do
    struct!(
      address_factory(),
      %{
        label: @long_text,
        street: @long_text,
        city: @long_text,
        state: @long_text,
        country: @long_text,
        zip_code: @long_text
      }
    )
  end

  def with_geocode(%Address{} = address) do
    geocode = insert(:geocode, address: address) |> without_assoc(:address)
    %{address | geocode: geocode}
  end

  # Geocode
  # ------------------------------------------------------------
  def geocode_factory do
    %Geocode{
      lat: "44.7287901",
      lng: "20.3751818051888",
      data: %{ # Couch Bar! ;)
        "address" => %{
          "city" => "Cukarica Urban Municipality",
          "country" => "Serbia",
          "country_code" => "rs",
          "county" => "City of Belgrade",
          "house_number" => "69",
          "neighbourhood" => "Тараиш",
          "postcode" => "11250",
          "road" => "Радних акција",
          "state" => "Central Serbia",
          "suburb" => "Zeleznik"
        },
        "boundingbox" => ["44.7287052", "44.7288606", "20.375084", "20.3752775"],
        "class" => "building",
        "display_name" => "69, Радних акција, Тараиш, Zeleznik, Cukarica Urban Municipality, City of Belgrade, Central Serbia, 11250, Serbia",
        "importance" => 0.22100000000000003,
        "lat" => "44.7287901",
        "licence" => "Data © OpenStreetMap contributors, ODbL 1.0. https://osm.org/copyright",
        "lon" => "20.3751818051888",
        # credo:disable-for-next-line Credo.Check.Readability.LargeNumbers
        "osm_id" => 413883199,
        "osm_type" => "way",
        # credo:disable-for-next-line Credo.Check.Readability.LargeNumbers
        "place_id" => 167558366,
        "type" => "yes"
      }
    }
  end

  # Inventory
  # ================================================================================
  
  # Category
  # ------------------------------------------------------------
  def category_factory do
    %Category{
      name: sequence("Clothing")
    }
  end

  def invalid_short_category_factory do
    struct!(
      category_factory(),
      %{
        name: ""
      }
    )
  end

  def invalid_long_category_factory do
    struct!(
      category_factory(),
      %{
        name: @long_text
      }
    )
  end

  # Item
  # ------------------------------------------------------------
  def item_factory do
    %Item{
      name: sequence("Shirt"),

      category: build(:category)
    }
  end

  def invalid_short_item_factory do
    struct!(
      item_factory(),
      %{
        name: ""
      }
    )
  end

  def invalid_long_item_factory do
    struct!(
      item_factory(),
      %{
        name: @long_text
      }
    )
  end

  # Mod
  # ------------------------------------------------------------
  # NOTE: Every combination of mods already exists in the DB.
  #       Never use `insert(:mod)` in tests.
  #
  # TODO: randomly rotate through all possible combos
  def mod_factory do
    %Mod{
      gender: sequence(:gender, ["", "masc", "fem"]),
      age: sequence(:age, ["", "adult", "child", "baby"]),
      size: sequence(:size, ["", "small", "medium", "large", "x-large"]),
      season: sequence(:season, ["", "summer", "winter"])
    }
  end

  def invalid_unkown_mod_factory do
    %Mod{
      # This is to test an error, not a political commentary.  Distribute Aid is
      # an inclusive organization!  Non-binary / gender neutral items should
      # leave the gender field blank / nil.
      gender: "???",
      age: "???",
      size: "???",
      season: "???"
    }
  end

  # Packaging
  # ------------------------------------------------------------
  def packaging_factory do
    %Packaging{
      count: sequence(:count, &(&1 + 1000)), # 1000, 1001, ...
      type: "large bags",
      description: "Large, sturdy bags that contain about 4 trash bags worth of items.",
      photo: nil # TODO: test photo uploads
    }
  end

  def invalid_short_packaging_factory do
    struct!(
      packaging_factory(),
      %{
        count: -1,
        type: "",
      }
    )
  end

  def invalid_long_packaging_factor do
    struct!(
      packaging_factory(),
      %{
        type: @long_text
      }
    )
  end

  # Stock
  # ------------------------------------------------------------
  def stock_factory do
    %Stock{
      have: sequence(:count, &(&1 + 1000)), # 1000, 1001, ...
      available: 0,
      need: 0,
      unit: Enum.random(["items", "small bags", "large bags", "small boxes", "large boxes", "pallets"]),
      description: "We got shirts yo.",
      photo: nil, # TODO: test photo uploads

      project: build(:project),
      item: build(:item),
      mod: build(:mod),
      packaging: build(:packaging)
    }
  end

  def available_stock_factory do
    struct!(
      stock_factory(),
      %{
        available: sequence(:available, &(&1 + 500)) # 500, 501, ...
      }
    )
  end

  def need_stock_factory do
    struct!(
      stock_factory(),
      %{
        need: sequence(:need, &(&1 + 500)) # 500, 501, ...
      }
    )
  end

  def invalid_short_stock_factory do
    struct!(
      stock_factory(),
      %{
        have: -1,
        available: -1,
        need: -1
      }
    )
  end

  def invalid_long_stock_factory do
    struct!(
      stock_factory(),
      %{
        # available > have
        available: 1000,
        have: 500
      }
    )
  end

  def invalid_available_stock_factory do
    struct!(
      stock_factory(),
      %{
        # available > 0 & need > 0
        available: 1,
        need: 1
      }
    )
  end

  def stock_attrs_factory(%{project: %{id: project_id}} = _attrs) do
    %{
      "project_id" => project_id,

      "have" => sequence(:count, &(&1 + 1000)), # 1000, 1001, ...
      "need" => 0,
      "available" => 0,
      "unit" => Enum.random(["items", "small bags", "large bags", "small boxes", "large boxes", "pallets"]),
      "description" => "Tons of shirts yo.",
      "photo" => nil, # TODO: test photo uploads

      "item" => Map.put(string_params_for(:item), "category", string_params_for(:category)),
      "mod" => string_params_for(:mod),
      "packaging" => string_params_for(:packaging)
    }
  end

  # Shipments
  # ------------------------------------------------------------

  def shipment_factory do
    %Shipment{
      target_date: sequence(:target_date, &"1/1/#{2020 + &1}"),
      status: Enum.random(["planning", "ready", "underway", "received"]),
      description: sequence("I am a shipment description with stuff about shipments yeah!"),

      sender_address: "an address",
      receiver_address: "another address",

      transport_size: Enum.random([
        nil,
        "Full Truck (13m / 40ft)",
        "Half Truck (13m / 40ft)",
        "Individual Pallets",
        "Van",
        "Car",
        "Shipping Container",
        "Other"
      ]),

      items: "some stuff",
      funding: "$nothing",

      roles: [],
      routes: []
    }
  end

  def invalid_shipment_factory do
    struct!(
      shipment_factory(),
      %{
        status: "hello"
      }
    )
  end

  def with_role(shipment, group \\ %{}) do
    group = case group do
      %Group{} -> group
      _ -> insert(:group, group) # `group` is attrs for :group factory
    end

    role = insert(:shipment_role, %{shipment_id: shipment.id, group: group})

    # append the role to shipment.roles and return the shipment
    # credo:disable-for-next-line Credo.Check.Refactor.AppendSingleItem
    %{shipment | roles: shipment.roles ++ [role]}
  end

  def with_route(shipment, route \\ %{}) do
    route = case route do
      %Route{} -> route
      _ -> insert(:route, Map.merge(route, %{shipment_id: shipment.id}))
    end

    # append the route to shipment.routes and return the shipment
    # credo:disable-for-next-line Credo.Check.Refactor.AppendSingleItem
    %{shipment | routes: shipment.routes ++ [route]}
  end

  # Shipment Role
  # ------------------------------------------------------------

  def shipment_role_factory do
    role = %Role{
      supplier?: Enum.random([true, false]),
      receiver?: Enum.random([true, false]),
      organizer?: Enum.random([true, false]),
      funder?: Enum.random([true, false]),
      other?: Enum.random([true, false]),
      description: sequence("I am description #")
    }

    if role.supplier? or role.receiver? or role.organizer? or role.funder? do
      role
    else
      %{role | other?: true}
    end
  end

  def invalid_shipment_role_factory do
    struct!(
      shipment_role_factory(),
      %{
        supplier?: false,
        receiver?: false,
        organizer?: false,
        funder?: false,
        other?: false
      }
    )
  end

  # Shipment Route
  # ------------------------------------------------------------

  def route_factory do
    %Route{
      type: Enum.random(["Pickup", "Dropoff", sequence("Other")]),
      address: sequence("Somewhere"),
      date: sequence(:date, &Date.add(Date.utc_today(), &1)),
      checklist: ["here", "there"],
      groups: "x"
    }
  end

  def invalid_route_factory do
    struct!(
      route_factory(),
      %{
        type: "",
        address: "",
        date: ""
      }
    )
  end

  # Aid Taxonomy
  # ================================================================================
  
  # Category
  # ------------------------------------------------------------
  
  def aid_category_factory do
    %Ferry.AidTaxonomy.Category{
      name: sequence("Clothing"),
      items: []
    }
  end

  def invalid_aid_category_factory do
    invalid_short_aid_category_factory()
  end

  def invalid_short_aid_category_factory do
    struct!(
      aid_category_factory(),
      %{
        name: "Y"
      }
    )
  end

  def invalid_long_aid_category_factory do
    struct!(
      aid_category_factory(),
      %{
        # 33 characters long
        name: String.duplicate("YOLO", 8) <> "!"
      }
    )
  end

  def with_item(category, item_or_attrs \\ %{})

  def with_item(%Ferry.AidTaxonomy.Category{} = category, %Ferry.AidTaxonomy.Item{} = item) do
    items =
      [item | category.items]
      |> Enum.sort_by(&(&1.name))

    %{category | items: items}
  end

  def with_item(%Ferry.AidTaxonomy.Category{} = category, attrs) do
    item = insert(:aid_item, Map.merge(attrs, %{category: category}))
    with_item(category, item)
  end

  # Item
  # ------------------------------------------------------------

  def aid_item_factory do
    %Ferry.AidTaxonomy.Item{
      name: sequence("Shirt"),
      category: build(:aid_category),
      mods: []
    }
  end

  def invalid_aid_item_factory do
    invalid_short_aid_item_factory()
  end

  def invalid_short_aid_item_factory do
    struct!(
      aid_item_factory(),
      %{
        name: "Y"
      }
    )
  end

  def invalid_long_aid_item_factory do
    struct!(
      aid_item_factory(),
      %{
        # 33 characters long
        name: String.duplicate("YOLO", 8) <> "!"
      }
    )
  end

  # Mod
  # ------------------------------------------------------------
  def aid_mod_factory(attrs \\ %{}) do
    type = if attrs[:type] do
      attrs.type
    else
      Enum.random(["integer", "select", "multi-select"])
    end

    values = case type do
      "integer" -> nil
      "select" -> ["small", "large"]
      "multi-select" -> ["summer", "winter"]
    end

    mod = %Ferry.AidTaxonomy.Mod{
      name: sequence("Size"),
      description: sequence("I let you specify the sizes of things."),
      type: type,
      values: values,
      items: []
    }

    merge_attributes(mod, attrs)
  end

  def invalid_aid_mod_factory do
    invalid_short_aid_mod_factory()
  end

  def invalid_short_aid_mod_factory do
    struct!(
      aid_mod_factory(),
      %{
        name: "Y",
        type: "select",
        values: ["only 1 choice"]
      }
    )
  end

  def invalid_long_aid_mod_factory do
    struct!(
      aid_mod_factory(),
      %{
        # 33 characters long
        name: String.duplicate("YOLO", 8) <> "!"
      }
    )
  end

  def invalid_type_aid_mod_factory do
    struct!(
      aid_mod_factory(),
      %{
        type: "not an option"
      }
    )
  end


  # Aid
  # ================================================================================

  # Aid List
  # ------------------------------------------------------------

  def aid_list_factory(attrs \\ %{}) do
    attrs =
      if attrs[:available_list] == nil and attrs[:manifest_list] == nil and attrs[:needs_list] == nil do
        owner_options = [
          %{available_list: build(:available_list)},
          %{manifest_list: build(:manifest_list)},
          %{needs_list: build(:needs_list)},
        ]
        Map.merge(attrs, Enum.random(owner_options))
      else
        attrs
      end

    list = %AidList{
      entries: []
    }

    merge_attributes(list, attrs)
  end

  def invalid_aid_list_factory do

  end

  def invalid_owner_aid_list_factory do
    struct!(
      aid_list_factory(),
      %{

      }
    )
  end

  # Available List
  # ------------------------------------------------------------
  def available_list_factory do
    project = build(:project)
    address = build(:address, %{project: project})

    %AvailableList{
      at: address
    }
  end

  # Manifest List
  # ------------------------------------------------------------
  def manifest_list_factory do
    shipment = build(:shipment)
    sender = build(:shipment_role, %{shipment: shipment, group: build(:group)})
    receiver = build(:shipment_role, %{shipment: shipment, group: build(:group)})
    origin = build(:route, %{shipment: shipment})
    destination = build(:route, %{shipment: shipment})

    %ManifestList{
      packaging: sequence(:packaging, &"#{&1} pallets"),

      shipment: shipment,
      from: sender,
      to: receiver,
      origin: origin,
      destination: destination
    }
  end

  # Needs List
  # ------------------------------------------------------------
  # TODO: need to prevent needs lists from overlapping, probably using sequences
  #       OR that may be too complex here, & let the calling code handle it
  #          the helpers are very useful:
  #          1) list1 = insert(:needs_list)
  #          2) list2 = insert(:needs_list_after, %{to: list1.to})
  def needs_list_factory do
    from = Timex.today() |> Timex.beginning_of_month()
    to = from |> Timex.end_of_month()

    needs_list = %NeedsList{
      from: from,
      to: to,

      project: build(:project) |> without_assoc(:address)
    }

    aid_list = build(:aid_list, %{needs_list: needs_list})

    struct!(
      needs_list,
      %{
        entries: aid_list.entries
      }
    )
  end

  def needs_list_before_factory(%{from: from} = attrs) do
    before = from |> Timex.shift(days: -1)
    attrs = Map.merge(attrs, %{
      from: before |> Timex.shift(months: -1),
      to: before
    })
    struct!(needs_list_factory(), attrs)
  end

  def needs_list_start_overlap_factory(%{from: from} = attrs) do
    attrs = Map.merge(attrs, %{
      from: from |> Timex.shift(months: -1),
      to: from
    })
    struct!(needs_list_factory(), attrs)
  end

  def needs_list_end_overlap_factory(%{to: to} = attrs) do
    attrs = Map.merge(attrs, %{
      from: to,
      to: to |> Timex.shift(months: 1)
    })
    struct!(needs_list_factory(), attrs)    
  end

  def needs_list_after_factory(%{to: to} = attrs) do
    after_end = to |> Timex.shift(days: 1)
    attrs = Map.merge(attrs, %{
      from: after_end,
      to: after_end |> Timex.shift(months: 1)
    })
    struct!(needs_list_factory(), attrs)
  end

  def invalid_needs_list_factory do
    invalid_duration_needs_list_factory()
  end

  def invalid_duration_needs_list_factory do
    list = needs_list_factory()

    struct!(
      list,
      %{
        from: list.to,
        to: list.from
      }
    )
  end

  # Entry
  # ------------------------------------------------------------
  
  def entry_factory do
    %Entry{
      amount: sequence(:amount, &(&1 + 1000)), # 1000, 1001, ...

      list: build(:aid_list),
      item: build(:aid_item),
      mod_values: []
    }
  end

  # Mod Value
  # ------------------------------------------------------------
  def mod_value_factory(attrs) do
    mod = if attrs[:mod], do: attrs.mod, else: build(:aid_mod)

    value = case mod.type do
      "integer" -> sequence(:value, &(&1 + 1000)) # 1000, 1001, ...
      "select" -> Enum.random(mod.values)
      "multi-select" ->
        [Enum.random(mod.values), Enum.random(mod.values)]
        |> Enum.uniq()
    end

    %ModValue{
      value: value,
      mod: mod,
      entry: build(:entry)
    }
  end

end
