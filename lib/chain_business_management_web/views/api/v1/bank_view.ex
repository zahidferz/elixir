defmodule ChainBusinessManagementWeb.Api.V1.BankView do
  use ChainBusinessManagementWeb, :view

  def render("bank.json", %{bank: bank}) do
    %{
      id: bank.id,
      code: bank.code,
      logo: bank.logo,
      name: bank.name
    }
  end
end
