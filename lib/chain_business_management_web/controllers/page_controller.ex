defmodule ChainBusinessManagementWeb.PageController do
  use ChainBusinessManagementWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
