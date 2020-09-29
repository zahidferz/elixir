defmodule ChainBusinessManagement.Repo.Migrations.AddOperationStatus do
  use Ecto.Migration

  def change do
    create table(:account_operation_status) do
      add :name, :string, null: false

      timestamps()
    end
  end
end
