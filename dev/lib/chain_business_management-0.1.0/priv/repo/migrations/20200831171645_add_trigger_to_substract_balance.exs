defmodule ChainBusinessManagement.Repo.Migrations.AddTriggerToSubstractBalance do
  use Ecto.Migration

  def up do
    execute "
    CREATE OR REPLACE FUNCTION delete_account_operations()
      RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
    DECLARE
        old_total integer;
        new_total integer;
    BEGIN
        select account.account_balance into old_total from account where id = OLD.account_id;
        new_total = old_total - OLD.amount;
        update account set account_balance = new_total, updated_at = now() where id = OLD.account_id;
        RETURN OLD;
    END;
    $$;
    "

    execute "
    CREATE TRIGGER sale_account_operation_deletes
    AFTER DELETE on account_operations
    FOR EACH ROW
    EXECUTE PROCEDURE delete_account_operations();
    "
  end

  def down do
    execute "
    DROP TRIGGER IF EXISTS sale_account_operation_deletes ON account_operations;
    "

    execute "
    DROP FUNCTION IF EXISTS delete_account_operations();
    "
  end
end
