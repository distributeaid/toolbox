defmodule Ferry.ApiClient.Groups do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with Groups in tests.
  """

  import Ferry.ApiClient.Graphql

  @doc """
  Run a GraphQL query that counts groups
  """
  @spec count_groups(Plug.Conn.t()) :: map
  def count_groups(conn) do
    graphql(conn, """
    {
      countGroups
    }
    """)
  end

  @doc """
  Run a GraphQL query that retuns a collection
  of groups
  """
  @spec get_groups(Plug.Conn.t()) :: map
  def get_groups(conn) do
    graphql(conn, """
    {
      groups {
        id,
        name,
        description,
        location {
          province,
          country_code,
          postal_code
        }
      }
    }
    """)
  end

  @doc """
  Run a GraphQL query that retuns a single
  group, given its id
  """
  @spec get_group(Plug.Conn.t(), String.t()) :: map
  def get_group(conn, id) do
    graphql(conn, """
     {
      group(id: "#{id}") {
        id,
        name,
        description
      }
    }
    """)
  end

  @doc """
  Run a GraphQL mutation that creates a group
  """
  @spec create_group(Plug.Conn.t(), map) :: map
  def create_group(conn, group_attrs) do
    graphql(conn, """
    mutation {
      createGroup(
        groupInput: {
          name: "#{group_attrs.name}",
          slug: "#{group_attrs.slug}",

          description: "#{group_attrs.description}",
          slackChannelName: "#{group_attrs.slack_channel_name}",

          requestForm: "#{group_attrs.request_form}",
          requestFormResults: "#{group_attrs.request_form_results}",
          volunteerForm: "#{group_attrs.volunteer_form}",
          volunteerFormResults: "#{group_attrs.volunteer_form_results}",
          donationForm: "#{group_attrs.donation_form}",
          donationFormResults: "#{group_attrs.donation_form_results}",

          location: {
            province: "#{group_attrs.location.province}",
            country_code: "#{group_attrs.location.country_code}",
            postal_code: "#{group_attrs.location.postal_code}",
          }
        }
      ) {
        successful
        messages {
          field
          message
        }
        result {
          id,
          name,
          type,
          slug,
          slackChannelName,
          location {
            province,
            country_code,
            postal_code
          }
        }
      }
    }
    """)
  end

  @doc """
  Run a GraphQL mutation that attempts to create a group.

  The mutation is designed to return a validation error
  """
  @spec create_invalid_group(Plug.Conn.t(), map) :: map
  def create_invalid_group(conn, group_attrs) do
    graphql(conn, """
      mutation {
        createGroup(
          groupInput: {
            name: "#{group_attrs.name}"
          }
        ) {
          successful
          messages {
            field
            message
          }
          result {
            id
          }
        }
      }
    """)
  end

  @doc """
  Run a GraphQL mutation that updates an existing group,
  """
  @spec update_group(Plug.Conn.t(), map) :: map
  def update_group(conn, updates) do
    graphql(conn, """
      mutation {
        updateGroup(
          id: "#{updates.id}",
          groupInput: {
            name: "#{updates.name}",
            slug: "#{updates.slug}",
            description: "#{updates.description}",
            slackChannelName: "#{updates.slack_channel_name}",
            requestForm: "#{updates.request_form}",
            requestFormResults: "#{updates.request_form_results}",
            volunteerForm: "#{updates.volunteer_form}",
            volunteerFormResults: "#{updates.volunteer_form_results}",
            donationForm: "#{updates.donation_form}",
            donationFormResults: "#{updates.donation_form_results}"

            location: {
              province: "#{updates.location.province}",
              country_code: "#{updates.location.country_code}",
              postal_code: "#{updates.location.postal_code}",
            }
          }
        ) {
          successful
          messages {
            field
            message
          }
          result {
            id
            name
            description
          }
        }
      }

    """)
  end

  @doc """
  Run a GraphQL mutation that deletes a group, given its id
  """
  @spec delete_group(Plug.Conn.t(), String.t()) :: map()
  def delete_group(conn, id) do
    graphql(conn, """
      mutation {
        deleteGroup(id: "#{id}") {
          id
        }
      }
    """)
  end
end
