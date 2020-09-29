defmodule ChainBusinessManagementWeb.Api.V1.OperationView do
  use ChainBusinessManagementWeb, :view

  def render("index.json", %{operations: operations}) do
    %{data: render_many(operations, __MODULE__, "operation.json", as: :operation)}
  end

  def render("show.json", %{operation: operation}) do
    %{data: render_one(operation, __MODULE__, "operation.json", as: :operation)}
  end

  def render("operation.json", %{operation: operation}) do
    %{
      id: operation.id,
      amount: Money.to_string(operation.amount, symbol: false),
      branch_number: operation.branch_number,
      client_id: operation.client_id,
      company_number: operation.company_number,
      currency: operation.currency,
      operation_datetime: operation.operation_datetime,
      account_id: operation.account_id,
      tz_offset: operation.tz_offset,
      operation_status: operation.account_operation_status.name,
      operation_type: operation.account_operation_type.name
    }
  end
end
