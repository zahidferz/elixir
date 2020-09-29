defmodule ChainBusinessManagement.Accounts do
  @moduledoc """
  The Accounts context.
  """
  use Timex

  import Ecto.Query, warn: false
  alias Ecto.Multi

  alias ChainBusinessManagement.Repo

  alias ChainBusinessManagement.Accounts.{
    Account,
    AccountOperation,
    AccountOperationStatus,
    AccountOperationType,
    SaleAccountOperation
  }

  alias ChainBusinessManagement.Utils

  require Logger

  @account_operation_status %{received: 1, expected: 2, overdue: 3, cancelled: 4}
  @account_operation_types %{income: 1, expenses: 2}

  @doc """
  Returns the list of account.

  ## Examples

      iex> list_account()
      [%Account{}, ...]

  """
  @spec list_account() :: list(Account.t())
  def list_account do
    Repo.all(Account)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_account!(pos_integer()) :: Account.t() | Ecto.NoResultsError
  def get_account!(id), do: Repo.get!(Account, id)

  @doc """
  Returns an account associated for the given user_id.

  ## Examples
      iex> get_account_by_user_id("852cc8a9-7b95-473e-b5a3-0f816e734cbe")
      %Account{}

      iex> get_account_by_user_id("852cc8a9-7b95-473e-b5a3-0f8fdkljlks")
      nil
  """
  @spec get_account_by_user_id(String.t()) :: Account.t() | nil
  def get_account_by_user_id(user_id) when is_binary(user_id) do
    Repo.get_by(Account, user_id: user_id)
  end

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_account(map) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_account(Account.t(), map) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_account(Account.t()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %Account{}}

  """
  @spec change_account(Account.t(), map) :: Ecto.Changeset.t()
  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end

  @doc """
  Given an account struct preloads his banks_catalog association
  """
  @spec preload_bank_info(Account.t()) :: Account.t()
  def preload_bank_info(%Account{} = account) do
    Repo.preload(account, :banks_catalog)
  end

  @doc """
  Given a name, returns an operation_type associated
  """
  @spec get_operation_type_by_name(String.t()) ::
          {:ok, AccountOperationType.t()} | {:error, String.t()}
  def get_operation_type_by_name(name) do
    AccountOperationType
    |> Repo.get_by(name: name)
    |> case do
      nil -> {:error, "operation_type not found"}
      operation_type -> {:ok, operation_type}
    end
  end

  @doc """
  Given a name, returns an operation_status associated
  """
  @spec get_operation_status_by_name(String.t()) ::
          {:ok, AccountOperationStatus.t()} | {:error, String.t()}
  def get_operation_status_by_name(name) do
    AccountOperationStatus
    |> Repo.get_by(name: name)
    |> case do
      nil -> {:error, "operation_status not found"}
      operation_status -> {:ok, operation_status}
    end
  end

  @doc """
  Creates an account_operation.

  ## Examples

      iex> create_account_operation(%{field: value})
      {:ok, %Account{}}

      iex> create_account_operation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_account_operation(map) ::
          {:ok, AccountOperation.t()} | {:error, Ecto.Changeset.t()}
  def create_account_operation(attrs \\ %{}) do
    %AccountOperation{}
    |> AccountOperation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a sale_account_operation.

  ## Examples

      iex> create_sale_account_operation(%{field: value})
      {:ok, %SaleAccountOperation{}}

      iex> create_sale_account_operation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_sale_account_operation(map) ::
          {:ok, SaleAccountOperation.t()} | {:error, Ecto.Changeset.t()}
  def create_sale_account_operation(attrs \\ %{}) do
    %SaleAccountOperation{}
    |> SaleAccountOperation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Given an account_operation struct preloads his operation_status and operation_type

  **Note**: Do not use this function for many account_operations because it is inefficient
  """
  @spec preload_account_operation_type_and_status(AccountOperation.t()) :: AccountOperation.t()
  def preload_account_operation_type_and_status(%AccountOperation{} = operation) do
    operation
    |> Repo.preload(:account_operation_status)
    |> Repo.preload(:account_operation_type)
  end

  @doc """
  Given a sale_id and a list of operations for each one creates an `%AccountOperation{}` and a `%SaleAccountOperation{}`
  Everything runs in a transaction using `Ecto.Multi` if one insert fails it reverts everything.
  """
  @spec bulk_operations(String.t(), String.t(), list()) ::
          {:ok, map()} | {:error, tuple(), Ecto.Changeset.t(), map()}
  def bulk_operations(sale_id, sale_datetime, operations_params) do
    {:ok, sale_datetime} = Timex.parse(sale_datetime, "{ISO:Extended}")
    {offset, time_zone} = Utils.get_datetime_time_zone_and_offset(sale_datetime)

    operations_params
    |> Enum.reduce([Multi.new(), 0], fn op, [multi, op_id] ->
      changeset = AccountOperation.changeset(%AccountOperation{}, op)

      multi =
        multi
        |> Multi.insert({:operation, op_id}, changeset)
        |> Multi.run({:sale_operation, op_id}, fn _repo, records ->
          operation = Map.get(records, {:operation, op_id})

          params = %{
            sale_id: sale_id,
            sale_datetime: sale_datetime,
            tz_offset: offset,
            time_zone: time_zone,
            amount_paid: operation.amount,
            account_operation_id: operation.id
          }

          create_sale_account_operation(params)
        end)

      [multi, op_id + 1]
    end)
    |> List.first()
    |> Repo.transaction()
  end

  @doc """
    Delete a sale account operation and its account operations by a
    given sale id

    ## Examples

      iex> delete_sale_account_operations_by_sale_id('d7dbab4c-039d-4052-a059-0718d4d4a775')
      {:ok, %{delete_all: {5, nil}}}

      iex> delete_sale_account_operations_by_sale_id(12122)
      {:ok, %{delete_all: {0, nil}}}
  """
  @spec delete_sale_account_operations_by_sale_id(String.t()) ::
          {:ok, %{delete_all: {non_neg_integer(), nil}}}
  def delete_sale_account_operations_by_sale_id(sale_id) do
    account_operations =
      AccountOperation
      |> join(:inner, [aco], saco in SaleAccountOperation, on: aco.id == saco.account_operation_id)
      |> where([_aco, saco], saco.sale_id == ^sale_id)

    Multi.new()
    |> Multi.delete_all(:delete_all, account_operations)
    |> Repo.transaction()
  end

  @doc """
   Get a sale account operation(s) by a given sale id

    ## Examples

      iex> get_sale_account_operation_by_sale_id('d7dbab4c-039d-4052-a059-0718d4d4a775')
      [%SaleAccountOperation{}]

      iex> get_sale_account_operation_by_sale_id(12122)
      []
  """
  @spec get_sale_account_operations_by_sale_id(String.t()) :: [] | [%SaleAccountOperation{}]
  def get_sale_account_operations_by_sale_id(sale_id) do
    SaleAccountOperation
    |> where([saco], saco.sale_id == ^sale_id)
    |> Repo.all()
  end

  @doc """
    Sets expected account operations to overdue by a reference timestamp
    without timezone offset.

    ## Examples
    iex> set_overdue_expected_operations("2020-08-31T12:21:12Z")
      {1, nil}

    iex> set_overdue_expected_operations("2020-08-28T12:21:12Z")
      {0, nil}
  """
  @spec set_overdue_expected_operations(String.t()) :: {0, nil} | {non_neg_integer(), nil}
  def set_overdue_expected_operations(timestamp) do
    {:ok, datetime, _tz} = DateTime.from_iso8601(timestamp)

    AccountOperation
    |> where(
      fragment(
        "date_part('day', (operation_datetime + tz_offset * interval '1hour') - ?) <= -1",
        ^datetime
      )
    )
    |> Repo.update_all(set: [account_operation_status_id: @account_operation_status.overdue])
  end

  @doc """
    Get an account operation by id

  ## Examples
    iex> get_account_operation_by_id(1)
      %AccountOperation{}

    iex> get_account_operation_by_id(9999999)
      {:error, "account_operation not found"}
  """
  @spec get_account_operation_by_id(non_neg_integer()) ::
          {:error, String.t()} | {:ok, %AccountOperation{}}
  def get_account_operation_by_id(id) do
    AccountOperation
    |> Repo.get(id)
    |> case do
      nil -> {:error, "account_operation not found"}
      account_operation -> {:ok, account_operation}
    end
  end

  @doc """
   Get sales for a given company number and range of dates

    ## Examples
    iex> get_sales_sum_by_company(%{company_number: 24454, from: ~D["2020-01-01"], to: ~D["2020-02-01"]})
        %{
        "amount_total" => %Money{amount: 6464, currency: :MXN},
        "company_number" => 24454
      }

    iex> get_sales_sum_by_company(%{company_number: 9999999, from: ~D["2020-01-01"], to: ~D["2020-02-01"]})
      nil
  """
  @spec get_sales_sum_by_company(%{
          company_number: non_neg_integer(),
          from: Date,
          to: Date
        }) ::
          nil | %{amount_total: non_neg_integer(), company_number: non_neg_integer()}
  def get_sales_sum_by_company(%{company_number: company_number, from: from, to: to}) do
    SaleAccountOperation
    |> join(:left, [saco], aco in assoc(saco, :account_operations))
    |> where([_saco, aco], aco.company_number == ^company_number)
    |> where(
      fragment(
        "DATE(sale_datetime + s0.tz_offset * interval '1hour') >= ?",
        ^from
      )
    )
    |> where(
      fragment(
        "DATE(sale_datetime + s0.tz_offset * interval '1hour') <= ?",
        ^to
      )
    )
    |> group_by([_saco, aco], aco.company_number)
    |> select([saco, aco], %{
      amount_total: sum(saco.amount_paid),
      company_number: aco.company_number
    })
    |> Repo.one()
  end

  @doc """
   Get the current day sales for a given company number.

     ## Examples
    iex> get_sales_sum_by_company(%{company_number: 208250})
      %{
        "amount_total" => %Money{amount: 6464, currency: :MXN},
        "company_number" => 208250
      }

    iex> get_sales_sum_by_company(11111111)
      nil
  """
  @spec get_sales_sum_by_company(%{
          company_number: non_neg_integer()
        }) ::
          nil | %{amount_total: non_neg_integer(), company_number: non_neg_integer()}
  def get_sales_sum_by_company(%{company_number: company_number}) do
    {:ok, date_time_now} = DateTime.now("America/Mexico_City")
    date_now = DateTime.to_date(date_time_now)

    SaleAccountOperation
    |> join(:left, [saco], aco in assoc(saco, :account_operations))
    |> where([_saco, aco], aco.company_number == ^company_number)
    |> where(
      fragment(
        "DATE(sale_datetime + s0.tz_offset * interval '1hour') = ?",
        ^date_now
      )
    )
    |> group_by([_saco, aco], aco.company_number)
    |> select([saco, aco], %{
      amount_total: sum(saco.amount_paid),
      company_number: aco.company_number
    })
    |> Repo.one()
  end

  @doc """
  Given a company_number, returns the sumatory of the account_operations classified in 3 categories
  1. overdue.
  2. today: if a time_zone like (-5, -6) it's  notprovided, it gonna take America/Mexico_City as default.
  3. future.

      ## Examples
      iex> get_receivables(3, -5)
      %{
        overdue: 2_000_00,
        today: 7_000_00,
        expected: 23_000_00
      }
  """
  @spec get_receivables(pos_integer(), String.t() | integer()) :: %{
          today: Money.t(),
          overdue: Money.t(),
          expected: Money.t()
        }
  def get_receivables(company_number, time_zone \\ "America/Mexico_City") do
    today_datetime =
      time_zone
      |> Timex.now()

    today_date = Timex.to_date(today_datetime)

    base_query =
      AccountOperation
      |> where([ao], ao.company_number == ^company_number)
      |> where([ao], ao.account_operation_type_id == ^@account_operation_types.income)

    %{
      today: sum_expected_operations_amount_by_date(base_query, today_date),
      overdue: sum_overdue_operations_amount(base_query),
      expected: sum_expected_operations_amount(base_query, today_datetime)
    }
  end

  @spec sum_overdue_operations_amount(Ecto.Query.t()) :: Money.t()
  defp sum_overdue_operations_amount(query) do
    query
    |> where([ao], ao.account_operation_status_id == ^@account_operation_status.overdue)
    |> Repo.aggregate(:sum, :amount)
    |> case do
      nil -> Money.new(0)
      total -> total
    end
  end

  @spec sum_expected_operations_amount(Ecto.Query.t(), DateTime.t()) :: Money.t()
  defp sum_expected_operations_amount(query, date) do
    query
    |> where([ao], ao.account_operation_status_id == ^@account_operation_status.expected)
    |> where(
      [ao],
      fragment(
        "date_part('day', (operation_datetime + tz_offset * interval '1hour') - ?) > 1",
        ^date
      )
    )
    |> Repo.aggregate(:sum, :amount)
    |> case do
      nil -> Money.new(0)
      total -> total
    end
  end

  @spec sum_expected_operations_amount_by_date(Ecto.Query.t(), Date.t()) :: Money.t()
  defp sum_expected_operations_amount_by_date(query, date) do
    query
    |> where(
      [ao],
      fragment(
        "DATE(operation_datetime + tz_offset * interval '1hour') = ?",
        ^date
      )
    )
    |> Repo.aggregate(:sum, :amount)
    |> case do
      nil -> Money.new(0)
      total -> total
    end
  end

  @doc """
  Given a company number and a year, returns the sum of sales per month, and a year total.

  ## Examples
      iex> get_sales_sum_by_year(%{company_number: 208496, year: 2020})
      %{
        months: [
          %{month: 1, total: %Money{amount: 100000, currency: :MXN}},
          %{month: 2, total: %Money{amount: 200000, currency: :MXN}},
          %{month: 8, total: %Money{amount: 2800000, currency: :MXN}},
          %{month: 9, total: %Money{amount: 100000, currency: :MXN}}
        ],
        total: %Money{amount: 3200000, currency: :MXN}
      }

      iex> get_sales_sum_by_year(%{company_number: 208496, year: 2019})
      %{
        months: [],
        total: %Money{amount: 0, currency: :MXN}
      }
  """
  @spec get_sales_sum_by_year(%{company_number: pos_integer(), year: pos_integer()}) ::
          %{total: Money.t(), months: []}
          | %{total: Money.t(), months: [%{total: Money.t(), month: non_neg_integer()}]}
  def get_sales_sum_by_year(%{company_number: company_number, year: year}) do
    SaleAccountOperation
    |> join(:left, [sao], ao in AccountOperation, on: sao.account_operation_id == ao.id)
    |> join(:left, [_sao, ao], acc in Account, on: ao.account_id == acc.id)
    |> where([_sao, _ao, acc], acc.company_number == ^company_number)
    |> where(
      [sao, _ao, _acc],
      fragment(
        "date_part('year', DATE(? + ? * interval '1hour'))::INTEGER = ?",
        sao.sale_datetime,
        sao.tz_offset,
        ^year
      )
    )
    |> select([sao, _ao, _acc], %{
      total: fragment("sum(?)", sao.amount_paid),
      month: fragment("date_part('mon', ?)::INTEGER as month", sao.sale_datetime)
    })
    |> group_by([_sao, _ao], fragment("month"))
    |> order_by([_sao, _ao], fragment("month DESC"))
    |> Repo.all()
    |> Enum.reduce(%{total: Money.new(0), months: []}, fn month, acc ->
      total = Money.add(acc.total, month.total)
      acc = Map.put(acc, :total, total)
      months = [%{total: Money.new(month.total), month: month.month} | acc.months]
      Map.put(acc, :months, months)
    end)
  end

  def get_sales_sum_by_year(%{client_id: client_id, year: year}) do
    SaleAccountOperation
    |> join(:left, [sao], ao in AccountOperation, on: sao.account_operation_id == ao.id)
    |> where([_sao, ao], ao.client_id == ^client_id)
    |> where(
      [sao, _ao],
      fragment(
        "date_part('year', DATE(? + ? * interval '1hour'))::INTEGER = ?",
        sao.sale_datetime,
        sao.tz_offset,
        ^year
      )
    )
    |> select([sao, _ao], %{
      total: fragment("sum(?)", sao.amount_paid),
      month: fragment("date_part('mon', ?)::INTEGER as month", sao.sale_datetime)
    })
    |> group_by([_sao, _ao], fragment("month"))
    |> order_by([_sao, _ao], fragment("month DESC"))
    |> Repo.all()
    |> Enum.reduce(%{total: Money.new(0), months: []}, fn month, acc ->
      total = Money.add(acc.total, month.total)
      acc = Map.put(acc, :total, total)
      months = [%{total: Money.new(month.total), month: month.month} | acc.months]
      Map.put(acc, :months, months)
    end)
  end

  @doc """
   Given a client id , returns the year(s) that have at least a
   sale

    ## Examples
    iex> get_year_sales(%{client_id: "852cc8a9-7b95-473e-b5a3-0f816e734cbc"})
        [%{year: 2019}]
    iex> get_year_sales(%{client_id: "123cc8a9-7b55-473e-b5a3-0f816e734cbc"})
      []
  """
  @spec get_year_sales(%{client_id: Ecto.UUId}) :: [] | [%{year: pos_integer()}]
  def get_year_sales(%{client_id: client_id}) do
    SaleAccountOperation
    |> join(:left, [sao], ao in AccountOperation, on: sao.account_operation_id == ao.id)
    |> select([sao, _ao], %{
      year:
        fragment(
          "date_part('year', DATE(? + ? * interval '1hour'))::INTEGER as year",
          sao.sale_datetime,
          sao.tz_offset
        )
    })
    |> group_by([_sao, _ao], fragment("year"))
    |> order_by([_sao, _ao], fragment("year DESC"))
    |> where([_sao, ao], ao.client_id == ^client_id)
    |> Repo.all()
  end

  @doc """
   Given a company number, returns the year(s) that have at least a
   sale

    ## Examples
    iex> get_year_sales(%{company_number: 208496})
        [%{year: 2019}]
    iex> get_year_sales(%{company_number: 209950})
      []
  """
  def get_year_sales(%{company_number: company_number}) do
    SaleAccountOperation
    |> join(:left, [sao], ao in AccountOperation, on: sao.account_operation_id == ao.id)
    |> select([sao, _ao], %{
      year:
        fragment(
          "date_part('year', DATE(? + ? * interval '1hour'))::INTEGER as year",
          sao.sale_datetime,
          sao.tz_offset
        )
    })
    |> group_by([_sao, _ao], fragment("year"))
    |> order_by([_sao, _ao], fragment("year DESC"))
    |> where([_sao, ao], ao.company_number == ^company_number)
    |> Repo.all()
  end
end
