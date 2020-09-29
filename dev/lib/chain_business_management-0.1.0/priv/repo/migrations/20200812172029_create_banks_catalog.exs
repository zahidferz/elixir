defmodule ChainBusinessManagement.Repo.Migrations.CreateBanksCatalog do
  use Ecto.Migration

  def change do
    create table(:banks_catalog) do
      add :code, :string
      add :name, :string
      add :logo, :string
      add :enabled, :boolean, default: false, null: false

      timestamps()
    end
  end
end
