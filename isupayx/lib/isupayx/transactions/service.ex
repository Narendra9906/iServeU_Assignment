defmodule Isupayx.Transactions.Service do
  alias Isupayx.{Repo, Transaction, Merchant}
  alias Isupayx.Validation.Pipeline
  alias IsupayxWeb.ErrorBuilder
  alias Isupayx.Events.Publisher

  defp authenticate(conn) do
    case Plug.Conn.get_req_header(conn, "x-api-key") do
      [api_key] ->
        case Repo.get_by(Merchant, api_key: api_key) do
          nil ->
            ErrorBuilder.build(401, "AUTH_INVALID_KEY", "Invalid API key", "auth")
          merchant ->
            {:ok, merchant}
        end
      [] ->
        ErrorBuilder.build(401, "AUTH_MISSING_KEY", "Missing API key", "auth")
    end
  end

  def create_transaction(conn, params) do
    with {:ok, merchant} <- authenticate(conn),
         {:ok, validated_data} <- Pipeline.run(params, merchant),
         {:ok, txn} <- persist_transaction(validated_data)
    do
      # 🔥 Publish event here
      Publisher.publish("authorized", txn)

      case success_response(txn) do
        {:ok, response} ->
          {:ok, 201, response}
        other ->
          {:error, 500, %{success: false, error: %{message: "unexpected response", detail: other}}}
      end
    else
      {:error, status, error} ->
        {:error, status, error}
    end
  end


  defp persist_transaction(data) do
    merchant = data["merchant_struct"]
    payment_method = data["payment_method_struct"]

    attrs = %{
      amount: data["amount"],
      currency: data["currency"],
      status: "processing",
      reference_id: "txn_" <> Ecto.UUID.generate(),
      merchant_id: merchant.id,
      payment_method_id: payment_method.id
    }

    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  defp success_response(txn) do
    {:ok,
     %{
       success: true,
       data: %{
         transaction_id: txn.reference_id,
         amount: txn.amount,
         currency: txn.currency,
         status: txn.status
       },
       metadata: %{
         request_id: "req_" <> Ecto.UUID.generate(),
         timestamp: DateTime.utc_now(),
         version: "v1"
       }
     }}
  end
end
