defmodule Isupayx.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :amount, :integer
      add :currency, :string
      add :status, :string
      add :reference_id, :string
      add :merchant_id, references(:merchants, on_delete: :nothing)
      add :payment_method_id, references(:payment_methods, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:merchant_id])
    create index(:transactions, [:payment_method_id])
  end
end
