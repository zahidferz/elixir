defmodule ChainBusinessManagement.AccountsTest do
  use ChainBusinessManagement.DataCase
  use Timex

  alias ChainBusinessManagement.Accounts

  require Logger

  describe "account" do
    alias ChainBusinessManagement.Accounts.Account

    @valid_attrs %{
      account_balance: Money.new(42_00),
      account_initial_balance: Money.new(42_00),
      account_initial_balance_datetime: "2010-04-17T14:00:00Z",
      account_number: "some account_number",
      account_type: 2,
      branch_number: 42,
      clabe: "123456789123456789",
      company_number: 42,
      name: "some name",
      user_id: "7488a646-e31f-11e4-aace-600308960662"
    }
    @update_attrs %{
      account_balance: Money.new(43_00),
      account_initial_balance: Money.new(43_00),
      account_initial_balance_datetime: "2011-05-18T15:01:01Z",
      account_number: "some updated account_number",
      account_type: 1,
      branch_number: 43,
      clabe: "987654321987654321",
      company_number: 43,
      name: "some updated name",
      user_id: "7488a646-e31f-11e4-aace-600308960668"
    }
    @invalid_attrs %{
      account_balance: nil,
      account_initial_balance: nil,
      account_initial_balance_datetime: nil,
      account_number: nil,
      account_type: nil,
      branch_number: nil,
      clabe: nil,
      company_number: nil,
      name: nil,
      user_id: nil
    }

    def account_fixture_local(attrs \\ %{}) do
      bank = banks_catalog_fixture()

      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{bank_id: bank.id})
        |> Accounts.create_account()

      account
    end

    def get_current_datetime_mx() do
      {:ok, datetime_tz_now} =
        Timex.now("Etc/GMT+5")
        |> Timex.format("%FT%TZ", :strftime)

      datetime_tz_now
    end

    test "list_account/0 returns all account" do
      account = account_fixture_local()
      assert Accounts.list_account() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture_local()
      assert Accounts.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      bank = banks_catalog_fixture()
      attrs = Enum.into(@valid_attrs, %{bank_id: bank.id})
      assert {:ok, %Account{} = account} = Accounts.create_account(attrs)
      assert account.account_balance == Money.new(42_00)
      assert account.account_initial_balance == Money.new(42_00)

      assert account.account_initial_balance_datetime ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert account.account_number == "some account_number"
      assert account.account_type == 2
      assert account.branch_number == 42
      assert account.clabe == "123456789123456789"
      assert account.company_number == 42
      assert account.name == "some name"
      assert account.user_id == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture_local()
      assert {:ok, %Account{} = account} = Accounts.update_account(account, @update_attrs)
      assert account.account_balance == Money.new(43_00)
      assert account.account_initial_balance == Money.new(43_00)

      assert account.account_initial_balance_datetime ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert account.account_number == "some updated account_number"
      assert account.account_type == 1
      assert account.branch_number == 43
      assert account.clabe == "987654321987654321"
      assert account.company_number == 43
      assert account.name == "some updated name"
      assert account.user_id == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture_local()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_account(account, @invalid_attrs)
      assert account == Accounts.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture_local()
      assert {:ok, %Account{}} = Accounts.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture_local()
      assert %Ecto.Changeset{} = Accounts.change_account(account)
    end
  end

  describe "account_operation" do
    alias ChainBusinessManagement.Accounts.AccountOperation
    alias ChainBusinessManagement.Utils

    @valid_attrs %{
      amount: 1_000,
      client_id: "7488a646-e31f-11e4-aace-600308960662",
      company_number: 30_234,
      time_zone: "Etc/GMT+5",
      currency: "MXN",
      operation_datetime: "2020-10-10T20:00:00Z",
      account_operation_status_id: 1,
      account_operation_type_id: 1
    }
    @invalid_attrs %{}

    test "create_account_operation/1 with invalid attrs returns an changeset error" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account_operation(@invalid_attrs)
    end

    test "create_account_operation/1 with valid attrs returns an account_operation" do
      account = account_fixture()
      valid_attrs = Enum.into(@valid_attrs, %{account_id: account.id})
      {:ok, operation_datetime, _} = DateTime.from_iso8601("2020-10-10T20:00:00Z")

      assert {:ok, %AccountOperation{} = account_operation} =
               Accounts.create_account_operation(valid_attrs)

      assert account_operation.amount == Money.new(1_000)
      assert account_operation.client_id == "7488a646-e31f-11e4-aace-600308960662"
      assert account_operation.currency == "MXN"
      assert account_operation.operation_datetime == operation_datetime
      assert assert account_operation.account_operation_type_id == 1
      assert account_operation.account_id == account.id
      assert account_operation.branch_number == nil
    end

    test "set_overdue_expected_operations/1 with valid expected operation change its status to overdue" do
      account = account_fixture()

      overdue_op_datetime =
        Timex.now("Etc/GMT+5")
        |> Timex.shift(hours: -25)

      {offset, time_zone} = Utils.get_datetime_time_zone_and_offset(overdue_op_datetime)

      account_operation =
        account_operation_fixture(%{
          account_id: account.id,
          operation_datetime: overdue_op_datetime,
          time_zone: time_zone,
          tz_offset: offset,
          account_operation_status_id: 2
        })

      current_datetime = get_current_datetime_mx()
      Accounts.set_overdue_expected_operations(current_datetime)

      {:ok, %AccountOperation{} = overdue_account_operation} =
        Accounts.get_account_operation_by_id(account_operation.id)

      assert overdue_account_operation.id == account_operation.id
      assert overdue_account_operation.account_operation_status_id == 3
    end

    test "set_overdue_expected_operations/1 with valid expected operation status remain expected" do
      account = account_fixture()

      not_overdue_op_datetime =
        Timex.now("Etc/GMT+5")
        |> Timex.shift(hours: -23)

      {offset, time_zone} = Utils.get_datetime_time_zone_and_offset(not_overdue_op_datetime)

      new_account_operation =
        account_operation_fixture(%{
          account_id: account.id,
          operation_datetime: not_overdue_op_datetime,
          time_zone: time_zone,
          tz_offset: offset,
          account_operation_status_id: 2
        })

      current_datetime = get_current_datetime_mx()
      Accounts.set_overdue_expected_operations(current_datetime)

      {:ok, %AccountOperation{} = account_operation} =
        Accounts.get_account_operation_by_id(new_account_operation.id)

      assert account_operation.id == new_account_operation.id
      assert account_operation.account_operation_status_id == 2
    end

    test "get_account_operation_by_id/1 returns a result when given an existent id" do
      new_account = account_fixture()
      new_account_operation = account_operation_fixture(%{account_id: new_account.id})

      assert {:ok, %AccountOperation{} = account_operation} =
               Accounts.get_account_operation_by_id(new_account_operation.id)

      assert account_operation.id == new_account_operation.id
    end

    test "get_account_operation_by_id/1 raises Ecto no results error when unexistent id" do
      assert {:error, "account_operation not found"} =
               Accounts.get_account_operation_by_id(99_999_999)
    end
  end

  describe "account_operation_type" do
    alias ChainBusinessManagement.Accounts.AccountOperationType

    test "get_operation_type_by_name/1 with existant name returns an operation_type" do
      assert {:ok, %AccountOperationType{} = type} = Accounts.get_operation_type_by_name("income")
      assert type.id == 1
      assert type.name == "income"
    end

    test "get_operation_type_by_name/1 with non existant name returns an error tuple" do
      assert {:error, "operation_type not found"} =
               Accounts.get_operation_type_by_name("invalid_name")
    end
  end

  describe "account_operation_status" do
    alias ChainBusinessManagement.Accounts.AccountOperationStatus

    test "get_operation_type_by_name/1 with existant name returns an operation_status" do
      assert {:ok, %AccountOperationStatus{} = status} =
               Accounts.get_operation_status_by_name("received")

      assert status.id == 1
      assert status.name == "received"
    end

    test "get_operation_type_by_name/1 with non existant name returns an error tuple" do
      assert {:error, "operation_status not found"} =
               Accounts.get_operation_status_by_name("invalid_name")
    end
  end

  describe "receivables" do
    test "sum of overdues operations" do
      company_number_test = 108_564
      account = account_fixture(%{company_number: company_number_test})

      account_operation_fixture(%{
        account_id: account.id,
        account_operation_status_id: 3,
        amount: Money.new(10_000),
        company_number: company_number_test
      })

      account_operation_fixture(%{
        account_id: account.id,
        account_operation_status_id: 3,
        amount: Money.new(10_000),
        company_number: company_number_test
      })

      assert %{
               today: Money.new(0),
               expected: Money.new(0),
               overdue: Money.new(20_000)
             } == Accounts.get_receivables(account.company_number)
    end

    test "sum of expected operations" do
      company_number_test = 108_564
      account = account_fixture(%{company_number: company_number_test})
      operation_datetime = "2080-12-12T15:15:15-05:00"

      account_operation_fixture(%{
        account_id: account.id,
        account_operation_status_id: 2,
        operation_datetime: operation_datetime,
        amount: Money.new(10_000),
        company_number: company_number_test
      })

      account_operation_fixture(%{
        account_id: account.id,
        account_operation_status_id: 2,
        operation_datetime: operation_datetime,
        amount: Money.new(10_000),
        company_number: company_number_test
      })

      assert %{
               today: Money.new(0),
               expected: Money.new(20_000),
               overdue: Money.new(0)
             } == Accounts.get_receivables(account.company_number)
    end

    test "sum of today operations" do
      company_number_test = 108_564
      account = account_fixture(%{company_number: company_number_test})
      operation_datetime = Timex.now("-5")
      future_operation = Timex.shift(operation_datetime, days: 5)

      account_operation_fixture(%{
        account_id: account.id,
        account_operation_status_id: 2,
        operation_datetime: operation_datetime,
        amount: Money.new(10_000),
        company_number: company_number_test
      })

      account_operation_fixture(%{
        account_id: account.id,
        account_operation_status_id: 2,
        operation_datetime: operation_datetime,
        amount: Money.new(10_000),
        company_number: company_number_test
      })

      account_operation_fixture(%{
        account_id: account.id,
        account_operation_status_id: 2,
        operation_datetime: future_operation,
        amount: Money.new(10_000),
        company_number: company_number_test
      })

      assert %{
               today: Money.new(20_000),
               expected: Money.new(10_000),
               overdue: Money.new(0)
             } == Accounts.get_receivables(account.company_number)
    end
  end
end
