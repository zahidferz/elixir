defmodule ChainBusinessManagementWeb.Api.V1.SalesCompanyOperationController do
  use ChainBusinessManagementWeb, :controller

  alias ChainBusinessManagement.Accounts
  alias ChainBusinessManagementWeb.Schemas
  alias ChainBusinessManagementWeb.Schemas.Api.V1.{SalesCompanyOperationSchema}

  action_fallback ChainBusinessManagementWeb.Api.V1.FallbackController

  def show(
        conn,
        %{"company_number" => _company_number, "from" => _from, "to" => _to} = operation_params
      ) do
    with {:ok, operation_params} <-
           Schemas.validate_schema(SalesCompanyOperationSchema, operation_params),
         result = %{} <- Accounts.get_sales_sum_by_company(operation_params) do
      render(conn, "show.json", sale_company: result)
    end
  end

  def show(conn, %{"company_number" => _company_number} = operation_params) do
    with {:ok, operation_params} <-
           Schemas.validate_schema(SalesCompanyOperationSchema, operation_params),
         result = %{} <- Accounts.get_sales_sum_by_company(operation_params) do
      render(conn, "show.json", sale_company: result)
    end
  end
end
