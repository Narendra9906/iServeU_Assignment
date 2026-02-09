defmodule Isupayx.PaymentMethod do
  use Ecto.Schema
  import Ecto.Changeset

  schema "payment_methods" do
    field :name, :string
    field :code, :string
    field :status, :string
    field :min_amount, :integer
    field :max_amount, :integer

    has_many :transactions, Isupayx.Transaction
    has_many :merchant_payment_methods, Isupayx.MerchantPaymentMethod

    timestamps()
  end

  def changeset(pm, attrs) do
    pm
    |> cast(attrs, [:name, :code, :status, :min_amount, :max_amount])
    |> validate_required([:name, :code])
  end
end
