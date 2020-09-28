defmodule Ferry.Features.Shipments do
  use Ferry.FeatureCase,
    feature: :shipments,
    include: [:addresses, :groups]
end
