defmodule Ferry.AuthTest do

  use Ferry.DataCase

  alias Ferry.Auth

  # Auth
  # ==============================================================================
  describe "auth" do
    alias Ferry.Accounts
    alias Ferry.Profiles

    # Data & Helpers
    # ----------------------------------------------------------

    def user_and_group_fixtures() do
      {:ok, group} = Profiles.create_group(%{name: "Dundee Refugee Support"})
      {:ok, user} = Accounts.create_user(group, %{email: "ruby@awesome.com", password: "super-secret"})

      {user, group}
    end

    # Tests
    # ----------------------------------------------------------
    
    test "authenticate_user/2 accepts valid credentials and returns the user" do
      {user, _} = user_and_group_fixtures()
      assert {:ok, authenticated_user} = Auth.authenticate_user(user.email, user.password)
      assert user.id == authenticated_user.id
    end

    test "authenticate_user/2 rejects invalid credentials" do
      {user, _} = user_and_group_fixtures()

      # email not found
      assert {:error, _} = Auth.authenticate_user("does_not_exist@example.org", user.password)

      # wrong password
      assert {:error, _} = Auth.authenticate_user(user.email, "wrong-password")
    end

    test "login/2"

    test "load_current_user/2"

    test "logout/0"
  end

end
