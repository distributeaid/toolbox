defmodule FerryApi.Schema.SelfCare do
  use Absinthe.Schema.Notation

  object :self_care_queries do
    @desc "Health check"
    field :health_check, :string do
      resolve(fn _parent, _args, _resolution ->
        {:ok, "ok"}
      end)
    end
  end
end
