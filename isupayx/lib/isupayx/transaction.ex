defmodule Isupayx.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :amount, :integer
    field :currency, :string
    field :status, :string
    field :reference_id, :string

    belongs_to :merchant, Isupayx.Merchant
    belongs_to :payment_method, Isupayx.PaymentMethod

    timestamps()
  end

  def changeset(txn, attrs) do
    txn
    |> cast(attrs, [:amount, :currency, :status, :reference_id, :merchant_id, :payment_method_id])
    |> validate_required([:amount, :currency, :merchant_id, :payment_method_id])
  end
end
