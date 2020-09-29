defmodule ChainBusinessManagementWeb.Api.V1.SalesCompanyOperationView do
  use ChainBusinessManagementWeb, :view

  def render("show.json", %{sale_company: sale_company}) do
    %{data: render_one(sale_company, __MODULE__, "sale_company.json", as: :sale_company)}
  end

  def render("sale_company.json", %{sale_company: sale_company}) do
    %{
      company_number: sale_company.company_number,
      amount_total: Money.to_string(sale_company.amount_total, symbol: false)
    }
  end
end
