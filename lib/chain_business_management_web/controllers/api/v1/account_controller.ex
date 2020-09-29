defmodule ChainBusinessManagementWeb.Api.V1.AccountController do
  use ChainBusinessManagementWeb, :controller

  alias ChainBusinessManagement.{Accounts, Banks, Utils}

  action_fallback ChainBusinessManagementWeb.Api.V1.FallbackController

  def create(conn, %{"account" => account_params}) do
    bank_code = account_params["bank_code"] || ""

    with {:ok, bank} <- Banks.get_bank_by_code(bank_code),
         params <- replace_amonuts(account_params),
         params <- Enum.into(params, %{"bank_id" => bank.id}),
         {:ok, account} <- Accounts.create_account(params),
         account <- Accounts.preload_bank_info(account) do
      render(conn, "show.json", account: account)
    else
      {:error, "code_not_associated_with_bank"} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("invalid_bank_error.json", bank_code: bank_code)

      err ->
        err
    end
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    with account <- Accounts.get_account!(id),
         {:ok, account} <- Accounts.update_account(account, account_params),
         account <- Accounts.preload_bank_info(account) do
      render(conn, "show.json", account: account)
    end
  end

  defp replace_amonuts(params) do
    params
    |> Map.update!("account_balance", &Utils.to_money(&1))
    |> Map.update!("account_initial_balance", &Utils.to_money(&1))
  end
end
