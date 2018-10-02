defmodule Ferry.CRM do
  @moduledoc """
  The CRM context.
  """

  import Ecto.Query, warn: false
  alias Ferry.Repo

  alias Ferry.Profiles.{Group, Project}
  alias Ferry.CRM.Contact

  @doc """
  Returns the list of contacts for a group or project.

  ## Examples

      iex> list_contacts(%Group)()
      [%Contact{}, ...]

      iex> list_contacts(%Project)()
      [%Contact{}, ...]

  """
  def list_contacts(%Group{} = group) do
    Repo.all(
      from c in Contact,
        where: c.group_id == ^group.id,
        left_join: e in assoc(c, :emails),
        preload: [emails: e],
        order_by: [c.id, e.email]
    )
  end

  def list_contacts(%Project{} = project) do
    Repo.all(
      from c in Contact,
        where: c.project_id == ^project.id,
        left_join: e in assoc(c, :emails),
        preload: [emails: e],
        order_by: [c.id, e.email]
    )
  end

  @doc """
  Gets a single contact.

  Raises `Ecto.NoResultsError` if the Contact does not exist.

  ## Examples

      iex> get_contact!(123)
      %Contact{}

      iex> get_contact!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contact!(id) do
    contact_query =
      from c in Contact,
        left_join: e in assoc(c, :emails),
        preload: [emails: e],
        order_by: [e.email]

    Repo.get!(contact_query, id)
  end

  @doc """
  Creates a contact.

  ## Examples

      iex> create_contact(%Group{}, %{field: value})
      {:ok, %Contact{}}

      iex> create_contact(%Project{}, %{field: value})
      {:ok, %Contact{}}

      iex> create_contact(%Group{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

      iex> create_contact(%Project{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact(owner, attrs \\ %{})

  def create_contact(%Group{} = group, attrs) do
    %Contact{}
    |> Contact.changeset(attrs)
    |> Ecto.Changeset.put_change(:group_id, group.id)
    |> Repo.insert()
  end

  def create_contact(%Project{} = project, attrs) do
    %Contact{}
    |> Contact.changeset(attrs)
    |> Ecto.Changeset.put_change(:project_id, project.id)
    |> Repo.insert()
  end

  @doc """
  Updates a contact.

  ## Examples

      iex> update_contact(contact, %{field: new_value})
      {:ok, %Contact{}}

      iex> update_contact(contact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact(%Contact{} = contact, attrs) do
    contact
    |> Contact.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Contact.

  ## Examples

      iex> delete_contact(contact)
      {:ok, %Contact{}}

      iex> delete_contact(contact)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact(%Contact{} = contact) do
    Repo.delete(contact)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact changes.

  ## Examples

      iex> change_contact(contact)
      %Ecto.Changeset{source: %Contact{}}

  """
  def change_contact(%Contact{} = contact) do
    Contact.changeset(contact, %{})
  end
end
