defmodule Ferry.Factory do
  @moduledoc """
    Provides factory function for tests.

    Inspired by: https://github.com/digitalnatives/course_planner/blob/7c5017ffb6c1f068691c6e6f1a17dce10ba3f839/test/support/factory.ex
  """

  use ExMachina.Ecto, repo: Ferry.Repo

  alias Ferry.{
    Accounts.User,
    Inventory.Category,
    Inventory.Item,
    Inventory.Mod,
    Inventory.Packaging,
    Inventory.Stock,
    Links.Link,
    Locations.Address,
    Locations.Geocode,
    Profiles.Group,
    Profiles.Project
  }

  @long_text String.duplicate("x", 256)
  @long_email String.duplicate("x", 244) <> "@example.com"


  # ExMachina Factories
  # ==============================================================================
  # TODO: split up into model-specific files
  #       https://hexdocs.pm/ex_machina/readme.html#splitting-factories-into-separate-files

  # NOTE: @password must be the same in `conn_case.ex`
  @password "lasdjkf o827349081247SLKDJFSD87634784¡¨ˆ™˙´¨¥∂œ•ª¨∂"
  @password_hash User.encrypt_password(@password)

  # Group
  # ----------------------------------------------------------

  def group_factory do
    %Group{
      name: sequence("Food Clothing and Resistance Collective"),
      description: "We show solidarity with our neighbors by using mutual aid to collect food and clothing from the community and distribute it to those in need."
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

      group: build(:group)
    }
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
      zip_code: "106 81",

      geocode: build(:geocode)
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
        "osm_id" => 413883199,
        "osm_type" => "way",
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
      count: sequence(:count, &(&1 + 1)), # 1, 2, ...
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
      count: sequence(:count, &(&1 + 1)), # 1, 2, ...
      description: "We got shirts yo.",
      photo: nil, # TODO: test photo uploads

      project: build(:project),
      item: build(:item),
      mod: build(:mod),
      packaging: build(:packaging)
    }
  end

  def invalid_short_stock_factory do
    struct!(
      stock_factory(),
      %{
        count: -1,
      }
    )
  end

end
