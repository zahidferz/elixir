defmodule ChainBusinessManagementWeb.Api.V1.AccountView do
  use ChainBusinessManagementWeb, :view

  alias ChainBusinessManagementWeb.Api.V1.BankView

  require Logger

  def render("show.json", %{account: account}) do
    %{data: render_one(account, __MODULE__, "account.json", as: :account)}
  end

  def render("account.json", %{account: account}) do
    %{
      id: account.id,
      account_balance: Money.to_string(account.account_balance, symbol: false),
      account_initial_balance: Money.to_string(account.account_initial_balance, symbol: false),
      account_initial_balance_datetime: account.account_initial_balance_datetime,
      account_number: account.account_number,
      account_type: account.account_type,
      branch_number: account.branch_number,
      clabe: account.clabe,
      company_number: account.company_number,
      name: account.name,
      user_id: account.user_id,
      bank: render_one(account.banks_catalog, BankView, "bank.json", as: :bank)
    }
  end

  def render("invalid_bank_error.json", %{bank_code: bank_code}) do
    %{error: "#{bank_code} is not a valid bank code"}
  end
end
