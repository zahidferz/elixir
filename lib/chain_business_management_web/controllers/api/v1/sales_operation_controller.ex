defmodule ChainBusinessManagementWeb.Api.V1.SalesOperationController do
  use ChainBusinessManagementWeb, :controller

  alias ChainBusinessManagement.Accounts

  action_fallback ChainBusinessManagementWeb.Api.V1.FallbackController

  def delete(conn, %{"id" => id}) do
    Accounts.delete_sale_account_operations_by_sale_id(id)
    send_resp(conn, :no_content, "")
  end
end
