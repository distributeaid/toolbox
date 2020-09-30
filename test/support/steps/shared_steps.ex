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
end
