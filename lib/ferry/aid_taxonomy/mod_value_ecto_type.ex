defmodule Ferry.AidTaxonomy.ModValueEctoType do
  @moduledoc """
  A custom Ecto.Type to handle the polymorphc nature of ModValues.
  We essentially abuse maps to achieve this.

  Even though this is only used by ModValues, it is closely tied to the
  different types of Mods themselves and thus is part of the AidTaxonomy
  context. For example, in order for a new Mod.type to be implemented, the
  ModValueEctoType will need to be updated to recognize and handle it.

  Limitations:

    1) The type helps us serialize to / deserialize from the database, and can
       catch data-level errors.  However, the type CANNOT catch errors outside
       of the data it receives from the field it's set on.  For example, it
       will accept an integer even if the related Mod has a "select" type.
       Similarly, it will accept select / multi-select strings that may not
       actually be present as options in the Mod.

    2) `nil` values are always bypassed- they will always be handled in the
       default manner and none of these functions will be called on them.

  Due to the limitations noted above, it is HIGHLY RECOMMENDED that any code
  which uses this type also includes strong validations at the schema level to
  enforce application behavior, such as tying ModValues to their related Mods.
  """
  @behaviour Ecto.Type

  # Type
  # ------------------------------------------------------------
  # The underlying schema type.

  def type, do: :map

  # Cast
  # ------------------------------------------------------------
  # Cast values into the custom type.  This is used:
  #
  #   - when Ecto.Changeset casts parameters
  #   - when arguments are passed to Ecto.Query

  # number mod
  def cast(int) when is_integer(int) do
    {:ok, int}
  end

  # select mod
  def cast(string) when is_bitstring(string) do
    {:ok, string}
  end

  # multi-select mod
  #
  # See the TODOs below, however it may be better to be stricter here to prevent
  # swallowing errors in code that uses this Type.
  def cast(list) when is_list(list) do
    cond do
      # check if any list values aren't strings
      # TODO: try to cast list entries to strings before failing?
      Enum.any?(list, &(!is_bitstring(&1))) -> {:error, message: "each values must be a string"}
      # check that there are no duplicates
      # TODO: remove duplicates instead of failing?
      Enum.uniq(list) != list -> {:error, message: "values must be unique"}
      # good 2 go
      true -> {:ok, list}
    end
  end

  # We don't know how to cast anything else.
  def cast(_), do: :error

  # Load
  # ------------------------------------------------------------
  # Load values from the database into the custom type.

  # number mod
  def load(%{"value" => int}) when is_integer(int) do
    {:ok, int}
  end

  # select mod
  def load(%{"value" => string}) when is_bitstring(string) do
    {:ok, string}
  end

  # multi-select mod
  #
  # NOTE: This should remain strict, since there is no way to receive malformed
  #       data unless the database has been corrupted or dump(list) is broken.
  def load(%{"value" => list}) when is_list(list) do
    cond do
      # The database has corrupted data or dump(list) has an error. Yikes!
      Enum.any?(list, &(!is_bitstring(&1))) -> :error
      Enum.uniq(list) != list -> :error
      # good 2 go
      true -> {:ok, list}
    end
  end

  # We don't know how to load anything else.
  def load(_), do: :error

  # Dump
  # ------------------------------------------------------------
  # Dump data from the custom type to the underlying schema type, for example
  # to store it in the database.

  # number mods
  def dump(int) when is_integer(int) do
    {:ok, %{"value" => int}}
  end

  # select mods
  def dump(string) when is_bitstring(string) do
    {:ok, %{"value" => string}}
  end

  # multi-select mods
  #
  # See the TODOs below, however it may be better to be stricter here to prevent
  # swallowing errors in code that uses this Type.  
  def dump(list) when is_list(list) do
    cond do
      # check if any list values aren't strings
      # TODO: try to cast list entries to strings before failing?
      Enum.any?(list, &(!is_bitstring(&1))) -> :error
      # check that there are no duplicates
      # TODO: remove duplicates instead of failing?
      Enum.uniq(list) != list -> :error
      # good 2 go
      true -> {:ok, %{"value" => list}}
    end
  end

  # We don't know how to dump anything else.
  def dump(_), do: :error
end
