defmodule Ferry.Features.Steps.Shipments do
  use Ferry.FeatureCase,
    feature: :shipments,
    include: [:addresses, :groups]
end
