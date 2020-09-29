defmodule ChainBusinessManagement.Repo.Migrations.AddOperationTypesAndStatus do
  use Ecto.Migration

  def up do
    execute "
     INSERT INTO account_operation_type
     (name, inserted_at, updated_at)
     VALUES
     ('income', now(), now()),
     ('expenses', now(), now());
    "

    execute "
    INSERT INTO account_operation_status
    (name, inserted_at, updated_at)
    VALUES
    ('received', now(), now()),
    ('expected', now(), now()),
    ('overdue', now(), now()),
    ('cancelled', now(), now());
    "
  end

  def down do
    execute "DELETE FROM account_operation_type;"
    execute "DELETE FROM account_operation_status;"
  end
end
