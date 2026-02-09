defmodule IsupayxWeb.ErrorBuilder do
  def build(status, code, message, layer, details \\ []) do
    {:error, status,
     %{
       success: false,
       error: %{
         code: code,
         message: message,
         layer: layer,
         details: details
       },
       metadata: metadata()
     }}
  end

  def metadata do
    %{
      request_id: "req_" <> Ecto.UUID.generate(),
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      version: "v1"
    }
  end
end
