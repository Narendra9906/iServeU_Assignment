defmodule Isupayx.Validation.SchemaValidator do
  alias Isupayx.{Repo, PaymentMethod}
  alias IsupayxWeb.ErrorBuilder

  def validate(params) do
    cond do
      is_nil(params["amount"]) ->
        ErrorBuilder.build(400, "SCHEMA_MISSING_FIELD", "Amount is required", "schema")

      params["amount"] <= 0 ->
        ErrorBuilder.build(400, "SCHEMA_INVALID_AMOUNT", "Amount must be greater than 0", "schema")

      is_nil(params["payment_method"]) ->
        ErrorBuilder.build(400, "SCHEMA_MISSING_FIELD", "Payment method is required", "schema")

      true ->
        load_payment_method(params)
    end
  end

  defp load_payment_method(params) do
    try do
      case Repo.get_by(PaymentMethod, code: params["payment_method"]) do
        nil ->
          ErrorBuilder.build(400, "SCHEMA_INVALID_PAYMENT_METHOD", "Payment method not found", "schema")

        pm ->
          {:ok, Map.put(params, "payment_method_struct", pm)}
      end
    rescue
      Ecto.MultipleResultsError ->
        ErrorBuilder.build(400, "SCHEMA_INVALID_PAYMENT_METHOD", "Multiple payment methods found", "schema")
    end
  end
end
