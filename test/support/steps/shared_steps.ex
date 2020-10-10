defmodule Ferry.SharedSteps do
  use Cabbage.Feature

  defgiven ~r/^I am root$/, _vars, state do
    {:ok, %{state | token: "root"}}
  end

  defthen ~r/^I should have (?<count>\d+)$/, %{count: count}, state do
    assert String.to_integer(count) == state.result, debug("Expected #{count}", state)
  end

  defthen ~r/^it should be successful$/, _vars, state do
    assert state.successful, debug("Expected to be successful", state)
    assert [] == state.errors, debug("Expected no errors", state)
    assert [] == state.messages, debug("Expected no messages", state)
  end

  defthen ~r/^it should not be successful$/, _vars, state do
    refute state.successful, debug("Expected not to be successful", state)
  end

  defthen ~r/^I should have a list$/, _vars, state do
    assert is_list(state.result), debug("Expected a list", state)
  end

  defthen ~r/^it should have length (?<length>\d+)$/, %{length: length}, state do
    assert is_list(state.result), debug("Expected a list", state)

    assert String.to_integer(length) == length(state.result),
           debug("Expected a list with length #{length}", state)
  end

  defthen ~r/^it should have a (?<field>\w+)$/, %{field: field}, state do
    has_value = state.result[field] != nil

    assert has_value,
           debug("Expected field \"#{field}\" to have a value", state)
  end

  # Convenience step that asserts the current result
  # as a field with that name, and its value is a date in the future
  # This step assumes the field exists and is not nil
  defthen ~r/^field "(?<field>[^"]+)" should be in (?<days>\d+) days$/,
          %{field: field, days: days},
          state do
    actual = state.result[field]

    case Date.from_iso8601(actual) do
      {:error, _} ->
        debug("Expected #{actual} in field #{field} to be a date", state)
        |> flunk()

      {:ok, date} ->
        expected = String.to_integer(days)

        assert expected == Date.diff(date, Date.utc_today()),
               debug("Expected #{actual} in field #{field} to be a date in #{days} days", state)
    end
  end

  defthen ~r/^field "(?<field>[^"]+)" should have length (?<length>\d+)$/,
          %{field: field, length: length},
          state do
    value = state.result[field]

    assert value != nil,
           debug("Expected field \"#{field}\" to have a value", state)

    assert is_list(value),
           debug("Expected field \"#{field}\" to be a list", state)

    assert String.to_integer(length) == length(value),
           debug("Expected a list with length #{length} at \"#{field}\"", state)
  end

  defthen ~r/^it should have user message "(?<message>[^"]+)"$/, %{message: message}, state do
    assert 1 ==
             state.messages
             |> Enum.filter(fn msg -> msg["message"] == message end)
             |> Enum.count(),
           debug("Expected user message \"#{message}\"", state)
  end

  # This step modifies the existing package context,
  # and sets the given field to the given value. It does some introspection
  # in order to set the right value type. In order to achieve this,
  # we require that the field already exists in the given map
  # and has a non nil value
  defgiven ~r/^that "(?<context>[^"]+)" has "(?<field>[^"]+)" set to "(?<value>[^"]+)"$/,
           %{context: context, field: field, value: value},
           state do
    value_path = "#{context}.#{field}"
    existing_value = context_at!(state, value_path)

    # Typecast the given value to the type
    # defined by the existing value
    new_value =
      cond do
        is_integer(existing_value) ->
          String.to_integer(value)

        is_boolean(existing_value) ->
          value == "true"

        true ->
          value
      end

    existing_context = state.context[context]
    new_context = Map.put(existing_context, field, new_value)

    state
    |> with_context(context, new_context)
  end

  # A convenience step that sets today's with a given value
  # in the given context key
  defgiven ~r/^a "(?<name>[^"]+)" date$/,
           %{name: name},
           state do
    date = DateTime.utc_now()

    state
    |> with_context("#{name}_date", date)
  end

  # A convenience step that navigates a date in the future
  # and sets it in the context
  defgiven ~r/^a "(?<name>[^"]+)" date in (?<days>\d+) days$/,
           %{name: name, days: days},
           state do
    days = String.to_integer(days)

    date =
      DateTime.utc_now()
      |> DateTime.add(days * 24 * 3600, :second)

    state
    |> with_context("#{name}_date", date)
  end
end
