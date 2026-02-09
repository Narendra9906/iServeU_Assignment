defmodule Isupayx.Merchant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "merchants" do
    field :name, :string
    field :api_key, :string
    field :status, :string
    field :kyc_status, :string

    has_many :transactions, Isupayx.Transaction
    has_many :merchant_payment_methods, Isupayx.MerchantPaymentMethod

    timestamps()
  end

  def changeset(merchant, attrs) do
    merchant
    |> cast(attrs, [:name, :api_key, :status, :kyc_status])
    |> validate_required([:name, :api_key])
  end
end
