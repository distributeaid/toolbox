defmodule FerryWeb.RoleView do
  use FerryWeb, :view

  def select_group_options(groups, existing_roles) do
    existing_groups = Enum.map(existing_roles, fn role ->
      role.group
    end)

    options = groups
      # remove existing_groups from the options
      |> Enum.reject(fn group ->
        Enum.member?(existing_groups, group)
      end)

      # convert to options format
      |> Enum.map(fn group ->
        {group.name, group.id}
      end)

    # add an option for the placeholder
    [nil | options]
  end

  def display_role_attributes(role) do
    # check the roles in reverse order from how we want to display them, since we are prepending
    role_attributes = []

    role_attributes = if role.other? do
      ["Other Role" | role_attributes]
    else
      role_attributes
    end

    role_attributes = if role.funder? do
      ["Funder" | role_attributes]
    else
      role_attributes
    end

    role_attributes = if role.receiver? do
      ["Receiver" | role_attributes]
    else
      role_attributes
    end

    role_attributes = if role.supplier? do
      ["Supplier" | role_attributes]
    else
      role_attributes
    end

    role_attributes = if role.organizer? do
      ["Organizer" | role_attributes]
    else
      role_attributes
    end

    role_attributes = Enum.join(role_attributes, " // ")

    ~E(<strong><%= role_attributes %></strong>)
  end
end
