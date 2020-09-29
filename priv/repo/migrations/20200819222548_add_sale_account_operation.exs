defmodule ChainBusinessManagement.Repo.Migrations.AddSaleAccountOperation do
  use Ecto.Migration

  def change do
    create table(:sale_account_operations) do
      add :amount_paid, :integer, default: 0, null: false
      add :sale_id, :uuid, null: false
      add :sale_datetime, :utc_datetime, null: false
      add :time_zone, :string, null: false
      add :tz_offset, :integer, default: 0
      add :account_operation_id, references(:account_operations, on_delete: :delete_all)

      timestamps()
    end

    create index(:sale_account_operations, [:sale_id, :account_operation_id])
  end
end
