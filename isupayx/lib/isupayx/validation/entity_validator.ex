defmodule Isupayx.Validation.EntityValidator do
  alias Isupayx.{Repo, MerchantPaymentMethod}
  alias IsupayxWeb.ErrorBuilder

  def validate(data, merchant) do
    cond do
      merchant.status != "active" ->
        ErrorBuilder.build(
          403,
          "ENTITY_MERCHANT_INACTIVE",
          "Merchant is inactive",
          "entity"
        )

      merchant.kyc_status not in ["approved", "verified"] ->
        ErrorBuilder.build(
          403,
          "ENTITY_MERCHANT_KYC_NOT_APPROVED",
          "Merchant KYC not approved",
          "entity"
        )

      true ->
        validate_payment_method_support(data, merchant)
    end
  end

  defp validate_payment_method_support(data, merchant) do
    payment_method = data["payment_method_struct"]

    try do
      case Repo.get_by(
             MerchantPaymentMethod,
             merchant_id: merchant.id,
             payment_method_id: payment_method.id
           ) do
        nil ->
          ErrorBuilder.build(
            403,
            "ENTITY_PAYMENT_METHOD_NOT_ENABLED",
            "Payment method not enabled for merchant",
            "entity"
          )

        mpm ->
          if mpm.status != "active" do
            ErrorBuilder.build(
              403,
              "ENTITY_PAYMENT_METHOD_DISABLED",
              "Payment method disabled for merchant",
              "entity"
            )
          else
            {:ok, Map.put(Map.put(data, "merchant_struct", merchant), "payment_method_struct", payment_method)}
          end
      end
    rescue
      Ecto.MultipleResultsError ->
        ErrorBuilder.build(403, "ENTITY_MULTIPLE_RESULTS", "Multiple payment method configs found", "entity")
    end
  end
end
