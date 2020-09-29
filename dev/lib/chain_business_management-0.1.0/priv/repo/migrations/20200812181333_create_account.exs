defmodule ChainBusinessManagement.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table(:account) do
      add :account_balance, :bigint, default: 0, null: false
      add :account_initial_balance, :bigint, default: 0, null: false
      add :account_initial_balance_datetime, :utc_datetime, null: false
      add :account_number, :string, null: false
      add :account_type, :integer, null: false
      add :branch_number, :integer, default: nil, null: true
      add :bank_id, references(:banks_catalog, on_delete: :nothing)
      add :clabe, :string
      add :company_number, :integer, null: false
      add :name, :string
      add :user_id, :uuid, null: false

      timestamps()
    end

    create index(:account, [:bank_id])
    create index(:account, [:user_id])
  end
end
