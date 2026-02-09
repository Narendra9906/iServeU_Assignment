defmodule Isupayx.Validation.BusinessValidator do
  alias IsupayxWeb.ErrorBuilder

  def validate(data) do
    payment_method = data["payment_method_struct"]
    amount = data["amount"]

    cond do
      payment_method.status != "active" ->
        ErrorBuilder.build(422, "RULE_PAYMENT_METHOD_INACTIVE", "Payment method inactive", "business")

      amount < payment_method.min_amount ->
        ErrorBuilder.build(422, "RULE_AMOUNT_BELOW_MIN", "Amount below minimum allowed", "business")

      amount > payment_method.max_amount ->
        ErrorBuilder.build(422, "RULE_AMOUNT_ABOVE_MAX", "Amount exceeds maximum allowed", "business")

      true ->
        {:ok, data}
    end
  end
end
