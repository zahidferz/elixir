defmodule ChainBusinessManagement.Repo.Migrations.AddAccountOperations do
  use Ecto.Migration

  def change do
    create table(:account_operations) do
      add :amount, :integer, default: 0, null: false
      add :branch_number, :integer
      add :client_id, :uuid, null: false
      add :company_number, :integer
      add :currency, :string, default: "MXN", null: false
      add :operation_datetime, :utc_datetime, null: false
      add :time_zone, :string, null: false
      add :tz_offset, :integer, default: 0
      add :account_id, references(:account)
      add :account_operation_status_id, references(:account_operation_status)
      add :account_operation_type_id, references(:account_operation_type)

      timestamps()
    end

    create index(:account_operations, [:account_id])
    create index(:account_operations, [:account_id, :account_operation_status_id])
    create index(:account_operations, [:account_id, :account_operation_type_id])
  end
end
