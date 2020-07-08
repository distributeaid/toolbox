defmodule FerryApi.Schema.Dataloader.Repo do
  @moduledoc """
  A data source for Absinthe's Dataloader

  Dataloader data sources are just structs
  that encode a way of retrieving data in batches.

  In a Phoenix application you'll generally have
  one source per context, so that each context
  can control how its data is loadeds.

  For now we have a single Ecto source.

  """

  @doc """
  The `data/0` function creates an Ecto data source,
  to which you pass your repo and a query function.
  """
  @spec data :: Dataloader.Ecto.t()
  def data() do
    Dataloader.Ecto.new(Ferry.Repo, query: &query/2)
  end

  @doc """

  The `query/2` function is called every time you want
  to load something, and provides an opportunity
  to apply arguments or set defaults
  """
  @spec query(any, any) :: any
  def query(queryable, _params) do
    queryable
  end
end
