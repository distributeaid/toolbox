defmodule Ferry.FeatureCase do
  @moduledoc """

  Base macro for all BDD features

  """
  defp steps_module(feature) do
    Module.concat(Ferry, "#{String.capitalize(Atom.to_string(feature))}Steps")
  end

  @spec __using__(Keyword.t()) :: any()
  defmacro __using__(tags) do
    feature = tags[:feature]
    include = tags[:include] || []

    file = "#{feature}.feature"
    steps_module = steps_module(feature)

    # step modules to include in the feature
    included_step_modules = Enum.map(include, &steps_module(&1))

    quote do
      use Cabbage.Feature, file: unquote(file)

      # Import step definitions. We import the shared
      # steps and the steps for the feature. Then we also import
      # any context steps defined the :include key
      import_feature(Ferry.SharedSteps)
      import_feature(unquote(steps_module))
      Enum.each(unquote(included_step_modules), &import_feature(&1))

      import Plug.Conn
      import Phoenix.ConnTest
      import Ferry.ApiClient.GraphCase
      alias FerryWeb.Router.Helpers, as: Routes
      require Logger

      import Ferry.Factory

      # The default endpoint for testing
      @endpoint FerryWeb.Endpoint

      setup tags do
        # Do something when the scenario is done
        on_exit(fn ->
          nil
        end)

        :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ferry.Repo)
        Ecto.Adapters.SQL.Sandbox.mode(Ferry.Repo, {:shared, self()})

        conn =
          Phoenix.ConnTest.build_conn()
          |> Plug.Conn.put_req_header("authorization", "Bearer fake.token")

        # Build a state that holds the connection and well
        # known default keys that will be populated and read by steps
        %{
          conn: conn,
          debug: tags[:debug] || false,
          token: nil,
          result: nil,
          errors: [],
          messages: [],
          successful: nil,
          context: %{}
        }
      end

      # Returns the value at the given state path
      # The value is assumed to exist. Otherwise a meaningful error
      # is raised, so that it can be easily debugged
      defp context_at!(state, path) do
        with nil <-
               path
               |> String.split(".")
               |> Enum.reduce_while(state.context, fn
                 key, data when is_map(data) ->
                   {:cont, data[key]}

                 _, _ ->
                   {:halt, nil}
               end) do
          "No value found at \"context.#{path}\""
          |> debug(state)
          |> flunk
        end
      end

      # Writes the given context data at the given
      # key
      #
      defp with_context(%{context: context} = state, key, data) do
        {:ok, %{state | context: Map.put(context, key, data)}}
      end

      # Copies the last result into a named key so that it can
      # be referenced in later steps
      defp with_alias(state, opts) do
        case opts[:as] do
          nil ->
            {:ok, state}

          as ->
            context = Map.put(state.context, as, state.result)
            {:ok, Map.put(state, :context, context)}
        end
      end

      # Convenience function to be used within feature step definitions.
      # Puts the given payload into the scenario state, so that it can
      # be asserted in subsequent steps
      defp with_payload(
             state,
             %{
               "successful" => successful,
               "messages" => messages,
               "result" => result
             },
             errors,
             opts
           ) do
        state
        |> Map.merge(%{successful: successful, errors: errors, messages: messages, result: result})
        |> with_alias(opts)
      end

      # Puts the given result in the state. In this case, we don't have a
      # mutation payload, but we take some defaults and turn into a consistent
      # data structure for the rest of steps
      defp with_payload(state, result, errors, opts) do
        state
        |> Map.merge(%{successful: true, errors: errors, messages: [], result: result})
        |> with_alias(opts)
      end

      # Convenience function that builds a mutation, executes it then
      # finally populates the scenarion step with the obtained payload
      defp mutation(%{debug: debug, conn: conn} = state, name, body, opts \\ []) do
        request = "mutation { #{body} }"
        response = graphql(conn, request)

        if debug do
          IO.inspect(state: state |> Map.drop([:conn]), mutation: request, response: response)
        end

        %{"data" => doc} = response
        payload = doc[name]
        errors = response["errors"] || []
        state |> with_payload(payload, errors, opts)
      end

      defp mutation(state, name) do
        mutation(state, name, name)
      end

      # Convenience function that executes the given function and
      # asserts that it was successful. Otherwise, it will fail the scenario
      # and provide full details on the state. To be used in Given steps.
      defp mutation!(state, name, body, opts \\ []) do
        {:ok, state} = mutation(state, name, body, opts)

        assert state[:successful],
               debug("Expected mutation #{name} to be successful", state)

        {:ok, state}
      end

      defp mutation!(state, name) do
        mutation(state, name, name)
      end

      # Convenience function that builds a query, executes and populates the
      # state with the obtained payload
      defp query(%{debug: debug, conn: conn} = state, name, body, opts \\ []) do
        request = "query { #{body} }"
        response = graphql(conn, request)

        if debug do
          IO.inspect(state: state |> Map.drop([:conn]), query: request, response: response)
        end

        %{"data" => doc} = response
        payload = doc[name]
        errors = response["errors"] || []
        state |> with_payload(payload, errors, opts)
      end

      defp query(state, name), do: query(state, name, name)

      # Convenience function that can be used during assertions so that
      # we get a clear message about what failed, and what the contents
      # of the current scenario state is
      defp debug(message, state) do
        state = state |> Map.drop([:conn, :test_type])
        "#{message}. State: #{inspect(state, pretty: true)}"
      end
    end
  end
end
