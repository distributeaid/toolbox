# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Ferry.Repo.insert!(%Ferry.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ferry.Repo


# Inventory.Mod
# ------------------------------------------------------------
# TODO: needs to be in a production seed file that can handle multiple runs
#       without adding duplicate entries
alias Ferry.Inventory.Mod

genders = [nil, "masc", "fem"]
ages = [nil, "adult", "child", "baby"]
sizes = [nil, "small", "medium", "large", "x-large"]
seasons = [nil, "summer", "winter"]

Enum.each(genders, fn gender ->
  Enum.each(ages, fn age ->
    Enum.each(sizes, fn size ->
      Enum.each(seasons, fn season ->
        insert!(%Mod{
          gender: gender,
          age: age,
          size: size,
          season: season
        })
      end)
    end)
  end)
end)
