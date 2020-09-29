defmodule ChainBusinessManagementWeb.Api.V1.SalesOperationControllerTest do
  @moduledoc false
  use ChainBusinessManagementWeb.ConnCase

  describe "delete sale account operations" do
    test "returs no content when a sale and its operation are deleted", %{conn: conn} do
      account = account_fixture()
      account_operation = account_operation_fixture(%{account_id: account.id})

      sale_account_operation =
        sale_account_operation_fixture(%{account_operation_id: account_operation.id})

      conn =
        delete(conn, Routes.sales_operation_path(conn, :delete, sale_account_operation.sale_id))

      assert response(conn, 204)
    end
  end
end
