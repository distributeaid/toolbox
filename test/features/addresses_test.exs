defmodule Ferry.Features.Addresses do
  use Ferry.FeatureCase,
    feature: :addresses,
    include: [:groups]
end
