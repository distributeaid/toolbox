defmodule Ferry.Schema do
  use Absinthe.Schema

  # import_types Ferry.Schema.DataTypes

  query do
    @desc "Health check"
    field :health_check, :string do
      resolve(fn _parent, _args, _resolution ->
        {:ok, "ok"}
      end)
    end
  end
end
