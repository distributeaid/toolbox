defmodule Ferry.Expectations.ListEntry do
  @moduledoc """
  Convenience module to express expectations on list entries
  """
  import ExUnit.Assertions

  @doc """
  Inspects the given list of entries, and looks for one that verifies
  the given specification in terms of amount, item name and mod values.
  """
  def assert_entry(spec, entries) do
    with :not_found <-
           Enum.find(entries, :not_found, fn entry ->
             matches?(spec, entry)
           end) do
      flunk("Expected entry #{inspect(spec, pretty: true)} in #{inspect(entries, pretty: true)}")
    end
  end

  # This function guard is designed to inspect graphql entries
  defp matches?(%{amount: amount, item: item, mods: expected_mod_values}, %{
         "amount" => amount,
         "item" => %{"category" => %{"name" => _}, "name" => item},
         "modValues" => mod_values
       }) do
    mod_values
    |> Enum.filter(fn %{"modValue" => %{"mod" => %{"name" => name}, "value" => value}} ->
      value == Map.get(expected_mod_values, String.to_existing_atom(name), nil)
    end)
    |> Enum.count() == length(mod_values)
  end

  defp matches?(_, _), do: false
end
