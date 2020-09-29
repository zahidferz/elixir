defmodule ChainBusinessManagement.Accounts.Account do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias ChainBusinessManagement.Accounts.AccountOperation
  alias ChainBusinessManagement.Banks.BanksCatalog

  @account_type_enum %{credit: 1, debit: 2}

  schema "account" do
    field :account_balance, Money.Ecto.Amount.Type, default: 0
    field :account_initial_balance, Money.Ecto.Amount.Type, default: 0
    field :account_initial_balance_datetime, :utc_datetime
    field :account_number, :string
    field :account_type, :integer
    field :branch_number, :integer, default: nil
    field :clabe, :string
    field :company_number, :integer
    field :name, :string
    field :user_id, Ecto.UUID
    has_many :account_operations, AccountOperation
    belongs_to :banks_catalog, BanksCatalog, foreign_key: :bank_id

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [
      :account_balance,
      :account_initial_balance,
      :account_initial_balance_datetime,
      :account_number,
      :account_type,
      :bank_id,
      :branch_number,
      :clabe,
      :company_number,
      :name,
      :user_id
    ])
    |> validate_required([
      :account_balance,
      :account_initial_balance,
      :account_initial_balance_datetime,
      :account_number,
      :account_type,
      :bank_id,
      :clabe,
      :company_number,
      :name,
      :user_id
    ])
    |> validate_number(:account_balance, greater_than_or_equal_to: 0)
    |> validate_number(:account_initial_balance, greater_than_or_equal_to: 0)
    |> validate_number(:company_number, greater_than_or_equal_to: 0)
    |> validate_length(:clabe, is: 18)
    |> validate_inclusion(:account_type, [@account_type_enum.credit, @account_type_enum.debit])
    |> foreign_key_constraint(:bank_id)
  end
end
