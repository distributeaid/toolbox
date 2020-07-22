defmodule Ferry.ApiClient.Project do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with Projects in tests.
  """

  import Ferry.ApiClient.Graphql

  @doc """
  Run a GraphQL query that counts projects
  """
  @spec count_projects(Plug.Conn.t()) :: map()
  def count_projects(conn) do
    graphql(conn, "{ countProjects }")
  end

  @doc """
  Run a GraphQL query that retuns a collection
  of projects
  """
  @spec get_projects(Plug.Conn.t()) :: map()
  def get_projects(conn) do
    graphql(conn, """
    {
      projects {
        id,
        name,
        description
      }
    }
    """)
  end

  @doc """
  Run a GraphQL query that retuns a single
  project, given its id.
  """
  @spec get_project(Plug.Conn.t(), String.t()) :: map()
  def get_project(conn, id) do
    graphql(conn, """
    {
      project(id: "#{id}") {
        id,
        name,
        description
      }
    }
    """)
  end

  @doc """
  Run a GraphQL query that retuns a single
  project, given its name.
  """
  @spec get_project_by_name(Plug.Conn.t(), String.t()) :: map()
  def get_project_by_name(conn, name) do
    graphql(conn, """
    {
      projectByName(name: "#{name}") {
        id,
        name,
        description
      }
    }
    """)
  end

  @doc """
  Run a GraphQL mutation that creates a project
  """
  @spec create_project(Plug.Conn.t(), map()) :: map()
  def create_project(conn, attrs) do
    graphql(conn, """
      mutation {
        createProject (
          projectInput: {
            group: "#{attrs.group}",
            name: "#{attrs.name}",
            description: "#{attrs.description}"
          }
        ) {
          successful,
          messages {
            field,
            message
          },
          result {
            id,
            name,
            description
          }
        }
      }
    """)
  end

  @doc """
  Run a GraphQL mutation that updates an existing project,
  """
  @spec update_project(Plug.Conn.t(), map()) :: map()
  def update_project(conn, attrs) do
    graphql(conn, """
      mutation {
        updateProject (
          projectInput: {
            name: "#{attrs.name}",
            description: "#{attrs.description}"
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
            name
          }
        }
      }
    """)
  end

  @doc """
  Run a GraphQL mutation that deletes a project, given its id
  """
  @spec delete_project(Plug.Conn.t(), String.t()) :: map()
  def delete_project(conn, id) do
    graphql(conn, """
    mutation {
      deleteProject(id: "#{id}") {
        successful,
        messages {
          field,
          message
        },
        result {
          id,
          name
        }
      }
    }
    """)
  end
end
