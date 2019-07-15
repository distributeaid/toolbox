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

    # add a default option
    [{"---", nil} | options]
  end

  def display_role_attributes(role) do
    cond do
      role.supplier? and role.receiver? -> ~E(<br /><small>Supplier, Receiver</small>)
      role.supplier? -> ~E(<br /><small>Supplier</small>)
      role.receiver? -> ~E(<br /><small>Receiver</small>)
      true -> nil
    end
  end
end
