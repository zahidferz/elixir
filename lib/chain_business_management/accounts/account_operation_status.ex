defmodule ChainBusinessManagement.Accounts.AccountOperationStatus do
  @moduledoc """
  Operation status like paid, received, expected
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ChainBusinessManagement.Accounts.AccountOperation

  schema "account_operation_status" do
    field(:name)

    has_many(:account_operations, AccountOperation)

    timestamps()
  end

  def changeset(account_operation, attrs) do
    account_operation
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
