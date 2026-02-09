defmodule Isupayx.MerchantPaymentMethod do
  use Ecto.Schema
  import Ecto.Changeset

  schema "merchant_payment_methods" do
    field :status, :string

    belongs_to :merchant, Isupayx.Merchant
    belongs_to :payment_method, Isupayx.PaymentMethod

    timestamps()
  end

  def changeset(mpm, attrs) do
    mpm
    |> cast(attrs, [:status, :merchant_id, :payment_method_id])
    |> validate_required([:merchant_id, :payment_method_id])
  end
end
