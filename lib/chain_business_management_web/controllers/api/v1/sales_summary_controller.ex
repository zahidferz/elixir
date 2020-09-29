defmodule ChainBusinessManagementWeb.Api.V1.SalesSummaryController do
  use ChainBusinessManagementWeb, :controller

  alias ChainBusinessManagement.Accounts
  alias ChainBusinessManagementWeb.Schemas

  alias ChainBusinessManagementWeb.Api.V1.Utils.ConnUtils
  alias ChainBusinessManagementWeb.Schemas.Api.V1.{MonthlySalesSchema, YearSalesSchema}

  action_fallback ChainBusinessManagementWeb.Api.V1.FallbackController

  def monthly_sales(conn, _params) do
    operation_params = ConnUtils.headers_to_map(conn, ["company_number", "client_id", "year"])

    with {:ok, operation_params} <-
           Schemas.validate_schema(MonthlySalesSchema, operation_params) do
      monthly_sales = Accounts.get_sales_sum_by_year(operation_params)
      render(conn, "monthly_sales.json", monthly_sales: monthly_sales)
    end
  end

  def year_sales(conn, _params) do
    operation_params = ConnUtils.headers_to_map(conn, ["client_id", "company_number"])

    with {:ok, operation_params} <-
           Schemas.validate_schema(YearSalesSchema, operation_params) do
      year_sales = Accounts.get_year_sales(operation_params)
      render(conn, "year_sales.json", year_sales: year_sales)
    end
  end
end
