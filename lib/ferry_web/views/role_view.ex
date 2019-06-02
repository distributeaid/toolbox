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
end
