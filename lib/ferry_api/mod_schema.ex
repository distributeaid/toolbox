defmodule FerryApi.Schema.Mod do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload
  alias Ferry.AidTaxonomy
  alias FerryApi.Middleware

  object :mod_queries do
    @desc "Get the # of mods"
    field :count_mods, :integer do
      resolve(&count_mods/3)
    end
  end

  object :mod_mutations do
  end

  @doc """
  Graphql resolver that returns the total number of mods
  """
  @spec count_mods(map(), map(), Absinthe.Resolution.t()) :: {:ok, non_neg_integer()}
  def count_mods(_parent, _args, _resolution) do
    {:ok, length(AidTaxonomy.list_mods())}
  end
end
