defmodule Ferry.GlobalFeatures do
  use Cabbage.Feature

  defgiven ~r/^I am root$/, _vars, state do
    {:ok, %{state | token: "root"}}
  end

  defthen ~r/^I should have (?<count>\d+)$/, %{count: count}, %{last: actual} do
    assert String.to_integer(count) == actual, "Expected #{actual} to be #{count}"
  end

  defthen ~r/^I should have an empty list$/, _, %{last: actual} do
    assert 0 == length(actual), "Expected an empty list, got: #{inspect(actual)}"
  end
end
