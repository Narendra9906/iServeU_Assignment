defmodule Isupayx.Repo.Migrations.CreatePaymentMethods do
  use Ecto.Migration

  def change do
    create table(:payment_methods) do
      add :name, :string
      add :code, :string
      add :status, :string
      add :min_amount, :integer
      add :max_amount, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
