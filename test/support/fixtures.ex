defmodule ChainBusinessManagement.Fixtures do
  @moduledoc """
  This module defines operations to interact with db.
  Must be used as helpers for tests
  """
  alias ChainBusinessManagement.{Accounts, Banks}

  @valid_acccount_attrs %{
    account_balance: Money.new(42_00),
    account_initial_balance: Money.new(42_00),
    account_initial_balance_datetime: "2010-04-17T14:00:00Z",
    account_number: "some account_number",
    account_type: 2,
    bank_id: 1,
    branch_number: 42,
    clabe: "123456789123456789",
    company_number: 42,
    name: "some name",
    user_id: "7488a646-e31f-11e4-aace-600308960662"
  }

  @valid_account_operation %{
    amount: 10_000,
    client_id: "d7dbab4c-039d-4052-a059-0718d4d4a775",
    currency: "MXN",
    account_id: 99_999,
    time_zone: "Etc/GMT+5",
    tz_offset: 0,
    operation_datetime: "2020-08-25T12:01:01",
    account_operation_status_id: 1,
    account_operation_type_id: 1
  }

  @valid_sale_account_oepration %{
    amount_paid: 500,
    sale_id: "d7dbab4c-039d-4052-a059-0718d4d4a775",
    time_zone: "Etc/GMT+5",
    tz_offset: 0,
    sale_datetime: "2020-08-25T12:01:01",
    account_operation_id: 99_999
  }

  @valid_bank_attrs %{enabled: true, logo: "some logo", name: "some name", code: "000"}

  @spec banks_catalog_fixture(map) :: Banks.BanksCatalog.t()
  def banks_catalog_fixture(attrs \\ %{}) do
    {:ok, banks_catalog} =
      attrs
      |> Enum.into(@valid_bank_attrs)
      |> replace_values(attrs)
      |> Banks.create_banks_catalog()

    banks_catalog
  end

  @spec account_fixture(map) :: Accounts.Account.t()
  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(@valid_acccount_attrs)
      |> replace_values(attrs)
      |> Accounts.create_account()

    account
  end

  @spec account_operation_fixture(map) :: Accounts.AccountOperation.t()
  def account_operation_fixture(attrs \\ %{}) do
    {:ok, account_operation} =
      attrs
      |> Enum.into(@valid_account_operation)
      |> replace_values(attrs)
      |> Accounts.create_account_operation()

    account_operation
  end

  @spec sale_account_operation_fixture(map) :: Accounts.SaleAccountOperation.t()
  def sale_account_operation_fixture(attrs \\ %{}) do
    {:ok, sale_account_operation} =
      attrs
      |> Enum.into(@valid_sale_account_oepration)
      |> replace_values(attrs)
      |> Accounts.create_sale_account_operation()

    sale_account_operation
  end

  defp replace_values(values, new_values) do
    Enum.reduce(new_values, values, fn {key, value}, acc ->
      Map.replace!(acc, key, value)
    end)
  end
end
