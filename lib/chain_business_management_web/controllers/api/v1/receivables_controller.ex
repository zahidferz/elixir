defmodule ChainBusinessManagementWeb.Api.V1.ReceivablesController do
  use ChainBusinessManagementWeb, :controller

  alias ChainBusinessManagement.Accounts

  action_fallback ChainBusinessManagementWeb.Api.V1.FallbackController

  require Logger

  def index(conn, %{"company_number" => company_number}) do
    {time_zone, _} = List.pop_at(get_req_header(conn, "time-zone"), 0, "America/Mexico_City")
    balance = Accounts.get_receivables(company_number, time_zone)

    render(conn, "index.json", balance: balance)
  end
end
