defmodule ChainBusinessManagementWeb.Api.V1.SalesSummaryView do
  use ChainBusinessManagementWeb, :view

  def render("monthly_sales.json", %{monthly_sales: monthly_sales}) do
    %{
      data: render_one(monthly_sales, __MODULE__, "monthly_sales_sum.json", as: :monthly_sales)
    }
  end

  def render("monthly_sales_sum.json", %{monthly_sales: monthly_sales}) do
    months =
      monthly_sales.months
      |> Enum.map(fn %{total: total, month: month} ->
        %{total: Money.to_string(total, symbol: false), currency: total.currency, month: month}
      end)

    %{
      total: Money.to_string(monthly_sales.total, symbol: false),
      months: months
    }
  end

  def render("year_sales.json", %{year_sales: year_sales}) do
    %{
      data: render_one(year_sales, __MODULE__, "year_sales_list.json", as: :year_sales)
    }
  end

  def render("year_sales_list.json", %{year_sales: year_sales}) do
    year_sales
    |> Enum.map(fn year -> year.year end)
  end
end
