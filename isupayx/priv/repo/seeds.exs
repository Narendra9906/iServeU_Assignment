# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Isupayx.Repo.insert!(%Isupayx.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Isupayx.Repo
alias Isupayx.Merchant
alias Isupayx.PaymentMethod
alias Isupayx.MerchantPaymentMethod

# Create merchant if it doesn't exist
merchant = case Repo.get_by(Merchant, api_key: "test_key") do
  nil ->
    Repo.insert!(%Merchant{
      api_key: "test_key",
      name: "Test Merchant",
      status: "active",
      kyc_status: "approved"
    })
  m -> m
end

# Insert payment methods
upi = Repo.insert!(%PaymentMethod{
  name: "UPI",
  code: "upi",
  status: "active",
  min_amount: 1,
  max_amount: 200000
})

cc = Repo.insert!(%PaymentMethod{
  name: "Credit Card",
  code: "credit_card",
  status: "active",
  min_amount: 100,
  max_amount: 500000
})

# Link merchant to payment methods
Repo.insert!(%MerchantPaymentMethod{
  merchant_id: merchant.id,
  payment_method_id: upi.id,
  status: "active"
})

Repo.insert!(%MerchantPaymentMethod{
  merchant_id: merchant.id,
  payment_method_id: cc.id,
  status: "active"
})
