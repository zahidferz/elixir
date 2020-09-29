defmodule ChainBusinessManagement.Accounts.AccountOperation do
  @moduledoc """
  Represent all the operations from an account in chain
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ChainBusinessManagement.Accounts.{
    Account,
    AccountOperationStatus,
    AccountOperationType,
    SaleAccountOperation
  }

  @currencies ["MXN", "USD", "EUR"]

  schema "account_operations" do
    field(:amount, Money.Ecto.Amount.Type)
    field(:branch_number, :integer)
    field(:client_id, Ecto.UUID)
    field(:company_number, :integer)
    field(:currency, :string)
    field(:time_zone, :string)
    field(:tz_offset, :integer, default: 0)
    field(:operation_datetime, :utc_datetime)

    has_many :sale_account_operations, SaleAccountOperation
    belongs_to(:account, Account)
    belongs_to(:account_operation_status, AccountOperationStatus)
    belongs_to(:account_operation_type, AccountOperationType)

    timestamps()
  end

  def changeset(account_operation, attrs) do
    account_operation
    |> cast(attrs, [
      :amount,
      :branch_number,
      :client_id,
      :company_number,
      :currency,
      :time_zone,
      :tz_offset,
      :operation_datetime,
      :account_id,
      :account_operation_status_id,
      :account_operation_type_id
    ])
    |> validate_required([
      :amount,
      :client_id,
      :currency,
      :time_zone,
      :tz_offset,
      :operation_datetime,
      :account_id,
      :account_operation_status_id,
      :account_operation_type_id
    ])
    |> validate_number(:amount, greater_than_or_equal_to: 1)
    |> validate_inclusion(:currency, @currencies)
    |> validate_number(:company_number, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:account_id)
    |> foreign_key_constraint(:account_operation_status_id)
    |> foreign_key_constraint(:account_operation_type_id)
  end
end
