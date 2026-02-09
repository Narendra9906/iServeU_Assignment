defmodule Isupayx.Repo.Migrations.CreateMerchantPaymentMethods do
  use Ecto.Migration

  def change do
    create table(:merchant_payment_methods) do
      add :status, :string
      add :merchant_id, references(:merchants, on_delete: :nothing)
      add :payment_method_id, references(:payment_methods, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:merchant_payment_methods, [:merchant_id])
    create index(:merchant_payment_methods, [:payment_method_id])
  end
end
