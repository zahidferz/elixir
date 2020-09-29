defmodule ChainBusinessManagement.Repo.Migrations.AddTriggersToSumAccountBalance do
  use Ecto.Migration

  def up do
    execute "
    CREATE OR REPLACE FUNCTION sum_account_operations()
      RETURNS TRIGGER
      LANGUAGE plpgsql
      AS $$
      DECLARE
          old_total integer;
          new_total integer;
    BEGIN
      select account.account_balance into old_total from account where id = NEW.account_id;
      new_total = old_total + NEW.amount;
      update account set account_balance = new_total, updated_at = now() where id = NEW.account_id;

      RETURN NEW;
    END;
    $$;
    "

    execute "
    CREATE TRIGGER sale_account_operation_changes
    AFTER INSERT on account_operations
    FOR EACH ROW
    EXECUTE PROCEDURE sum_account_operations();
    "
  end

  def down do
    execute "
    DROP TRIGGER IF EXISTS sale_account_operation_changes ON account_operations;
    "

    execute "
    DROP FUNCTION IF EXISTS sum_account_operations();
    "
  end
end
