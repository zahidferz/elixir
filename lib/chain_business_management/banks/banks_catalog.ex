defmodule ChainBusinessManagement.Banks.BanksCatalog do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias ChainBusinessManagement.Accounts.Account

  schema "banks_catalog" do
    field :code, :string
    field :enabled, :boolean, default: false
    field :logo, :string
    field :name, :string
    has_many :account, Account, foreign_key: :bank_id

    timestamps()
  end

  @doc false
  @spec changeset(map, map) :: Ecto.Changeset.t()
  def changeset(banks_catalog, attrs) do
    banks_catalog
    |> cast(attrs, [:code, :name, :logo, :enabled])
    |> validate_required([:code, :name, :logo, :enabled])
  end
end
