defmodule Ferry.EntryApiTest do
  use FerryWeb.ConnCase, async: true

  setup context do
    insert(:user)
    |> mock_sign_in

    Ferry.Fixture.NeedsWithEntry.setup(context)
  end

  describe "entry graphql api" do
  end
end
