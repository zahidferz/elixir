defmodule ChainBusinessManagement.Accounts.SaleAccountOperation do
  @moduledoc """
  Represent the relation between account operations and sales
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ChainBusinessManagement.Accounts.AccountOperation

  schema "sale_account_operations" do
    field :amount_paid, Money.Ecto.Amount.Type
    field :sale_id, Ecto.UUID
    field :sale_datetime, :utc_datetime
    field :tz_offset, :integer
    field :time_zone, :string

    belongs_to :account_operations, AccountOperation, foreign_key: :account_operation_id

    timestamps()
  end

  def changeset(sale_account_operation, attrs) do
    sale_account_operation
    |> cast(attrs, [
      :amount_paid,
      :sale_id,
      :account_operation_id,
      :sale_datetime,
      :tz_offset,
      :time_zone
    ])
    |> validate_required([
      :amount_paid,
      :sale_id,
      :account_operation_id,
      :sale_datetime,
      :tz_offset,
      :time_zone
    ])
    |> validate_number(:amount_paid, greater_than_or_equal_to: 1)
    |> foreign_key_constraint(:account_operation_id)
  end
end
