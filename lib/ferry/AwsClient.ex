defmodule Ferry.AwsClientBehaviour do
  @callback request(ExAws.Operation.JSON.t()) :: tuple()
end

defmodule Ferry.AwsClient do
  @behaviour Ferry.AwsClientBehaviour
  defdelegate request(operation), to: ExAws
end
