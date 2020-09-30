defmodule Ferry.ApiClient.Address do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with Addresses in tests.
  """

  import Ferry.ApiClient.GraphCase

  @doc """
  Run a GraphQL query that counts addresses
  """
  @spec count_addresses(Plug.Conn.t()) :: map()
  def count_addresses(conn) do
    graphql(conn, "{ countAddresses }")
  end

  @doc """
  Run a GraphQL query that retuns a collection
  of addresses
  """
  @spec get_addresses(Plug.Conn.t()) :: map()
  def get_addresses(conn) do
    graphql(conn, """
    {
      addresses {
        id,
        label
      }
    }
    """)
  end

  @doc """
  Run a GraphQL query that retuns a single
  address, given its name.
  """
  @spec get_address(Plug.Conn.t(), String.t()) :: map()
  def get_address(conn, id) do
    graphql(conn, """
    {
      address(id: "#{id}") {
        id,
        label
      }
    }
    """)
  end

  @default_address_attrs %{
    street: "street",
    city: "city",
    province: "province",
    country_code: "USA",
    postal_code: "zip"
  }

  @doc """
  Run a GraphQL mutation that creates an address
  """
  @spec create_address(Plug.Conn.t(), map()) :: map()
  def create_address(conn, attrs) do
    attrs = Map.merge(@default_address_attrs, attrs)

    graphql(conn, """
      mutation {
        createAddress (
          addressInput: {
            group: #{attrs.group},
            label: "#{attrs.label}",
            street: "#{attrs.street}",
            city: "#{attrs.city}",
            province: "#{attrs.province}",
            country_code: "#{attrs.country_code}",
            postal_code: "#{attrs.postal_code}",
            opening_hour: "9:00",
            closing_hour: "8:00",
            type: "industrial",
            has_loading_equipment: false,
            has_unloading_equipment: true,
            needs_appointment: true
          }
        ) {
          successful,
          messages {
            field,
            message
          },
          result {
            id,
            label
          }
        }
      }
    """)
  end

  @doc """
  Run a GraphQL mutation that updates an existing address
  """
  @spec update_address(Plug.Conn.t(), map()) :: map()
  def update_address(conn, attrs) do
    graphql(conn, """
      mutation {
        updateAddress (
          addressInput: {
            label: "#{attrs.label}"
          },
          id: "#{attrs.id}"
        ) {
          successful,
          messages {
            field,
            message
          },
          result {
            id,
            label
          }
        }
      }
    """)
  end

  @doc """
  Run a GraphQL mutation that deletes an address, given its id
  """
  @spec delete_address(Plug.Conn.t(), String.t()) :: map()
  def delete_address(conn, id) do
    graphql(conn, """
    mutation {
      deleteAddress(id: "#{id}") {
        successful,
        messages {
          field,
          message
        },
        result {
          id,
          label
        }
      }
    }
    """)
  end
end
