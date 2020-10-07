defmodule Ferry.Features.NeedsLists do
  use Ferry.FeatureCase,
    feature: :needs_lists,
    include: [:groups, :projects]
end
