defmodule Isupayx.Validation.Pipeline do
  alias Isupayx.Validation.{
    SchemaValidator,
    EntityValidator,
    BusinessValidator,
    ComplianceValidator,
    RiskValidator
  }

  def run(params, merchant) do
    with {:ok, data} <- SchemaValidator.validate(params),
         {:ok, data} <- EntityValidator.validate(data, merchant),
         {:ok, data} <- BusinessValidator.validate(data),
         {:ok, data} <- ComplianceValidator.validate(data),
         {:ok, data} <- RiskValidator.validate(data)
    do
      {:ok, data}
    end
  end
end
