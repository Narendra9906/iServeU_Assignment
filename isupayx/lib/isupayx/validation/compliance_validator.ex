defmodule Isupayx.Validation.ComplianceValidator do
  def validate(data) do
    if data["amount"] > 200_000 do
      {:ok, Map.put(data, "compliance_flags", ["AMOUNT_REPORTING"])}
    else
      {:ok, data}
    end
  end
end
