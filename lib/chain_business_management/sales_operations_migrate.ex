defmodule ChainBusinessManagement.SalesOperationsMigrate do
  @moduledoc """
    Migrates company sales
  """
  import Ecto.Query
  require Logger
  alias ChainBusinessManagement.{Accounts, IncomeSalesRepo, UsersRepo, Utils}

  @banks %{default: 93}
  @account_type %{credit: 1, debit: 2}
  @sale_status %{valid: 3}
  @account_operation_type %{income: 1}
  @account_operation_status %{received: 1}
  @timezone "Etc/GMT+5"

  @spec get_company_users(list(pos_integer())) :: list()
  defp get_company_users(company_numbers) do
    query =
      from us in "Users",
        join: uc in "UserCompany",
        on: us.userId == uc.userId,
        where: uc.companyNumber in ^company_numbers,
        select: %{
          user_id: fragment("CAST(? AS VARCHAR(255))", us.userId),
          company_number: uc.companyNumber
        }

    UsersRepo.all(query)
  end

  @spec get_valid_company_sales(list(pos_integer())) :: list()
  defp get_valid_company_sales(company_numbers) do
    query =
      from sa in "Sale",
        where: sa.companyNumber in ^company_numbers,
        where: sa.saleStatusId == ^@sale_status.valid,
        select: %{
          client_id: fragment("CAST(? AS VARCHAR(255))", sa.clientId),
          sale_id: fragment("CAST(? AS VARCHAR(255))", sa.saleId),
          sale_datetime: sa.date,
          amount: fragment("CAST(CAST(? as decimal(20,2)) AS VARCHAR)", sa.total),
          company_number: sa.companyNumber,
          currency: sa.currency
        }

    IncomeSalesRepo.all(query)
  end

  @doc """
    Migrate company sale operations from a given
    company numbers list. Creates a default
    account for every company and its respective
    sale account operations for every company sale

    ### Example
    iex > migrate([208496])
      :ok
    iex > migrate([209996])
      :ok
      [error] No users for a given company from list
  """
  @spec migrate(list(pos_integer())) :: :ok
  def migrate(company_numbers) when is_list(company_numbers) do
    with company_users = [_ | _] <- get_company_users(company_numbers),
         company_accounts <- create_company_account(company_users),
         company_sales <- get_valid_company_sales(company_numbers) do
      create_account_operations(company_accounts, company_sales)
    else
      [] -> Logger.error("No users for a given company from list")
    end
  end

  @spec create_company_account(list()) :: map()
  defp create_company_account(company_users) do
    company_users
    |> Enum.reduce([], fn company, acc ->
      %{
        account_initial_balance_datetime: DateTime.now!(@timezone),
        account_number: "n/a",
        account_type: @account_type.debit,
        bank_id: @banks.default,
        clabe: "000000000000000000",
        name: "Cuenta base"
      }
      |> Enum.into(company)
      |> Accounts.create_account()
      |> case do
        {:ok, company_account} -> [company_account | acc]
        {:error, _} -> acc
      end
    end)
    |> Enum.group_by(fn account -> account.company_number end)
  end

  @spec create_account_operations(map(), list()) :: :ok
  defp create_account_operations(company_accounts, company_sales) do
    company_sales
    |> Enum.each(fn sale ->
      sale_datetime = Timex.Timezone.convert(sale.sale_datetime, @timezone)
      {:ok, [account | _]} = Map.fetch(company_accounts, sale.company_number)

      case Accounts.bulk_operations(sale.sale_id, to_string(sale_datetime), [
             %{
               account_id: account.id,
               amount: String.to_float(sale.amount) |> Utils.to_money(),
               client_id: sale.client_id,
               company_number: sale.company_number,
               currency: sale.currency,
               operation_datetime: sale.sale_datetime,
               account_operation_type_id: @account_operation_type.income,
               account_operation_status_id: @account_operation_status.received,
               time_zone: sale_datetime.time_zone,
               tz_offset: sale_datetime.zone_abbr
             }
           ]) do
        {:error, _tuple, changeset, _map} ->
          Logger.error(
            "Changeset errors -> \n #{
              inspect(%{changes: changeset.changes, errors: changeset.errors})
            }"
          )

        {:ok, _map} ->
          update_sale_migration_status(sale.sale_id)
      end
    end)
  end

  defp update_sale_migration_status(sale_id) do
    query =
      from "Sale",
        where: [saleId: ^sale_id],
        update: [set: [finishedPrecalculatedMigration: true]]

    IncomeSalesRepo.update_all(query, [])
  end
end
