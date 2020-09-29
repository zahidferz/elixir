defmodule ChainBusinessManagementWeb.Api.V1.ReceivablesView do
  use ChainBusinessManagementWeb, :view

  def render("index.json", %{balance: balance}) do
    %{data: render_one(balance, __MODULE__, "balance.json", as: :balance)}
  end

  def render("balance.json", %{balance: balance}) do
    %{
      today: Money.to_string(balance.today),
      overdue: Money.to_string(balance.overdue),
      expected: Money.to_string(balance.expected)
    }
  end
end
