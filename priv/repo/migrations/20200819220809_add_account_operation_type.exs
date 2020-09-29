defmodule ChainBusinessManagement.Repo.Migrations.AddAccountOperationType do
  use Ecto.Migration

  def change do
    create table(:account_operation_type) do
      add :name, :string, null: false

      timestamps()
    end
  end
end
