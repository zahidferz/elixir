defmodule ChainBusinessManagement.UsersRepo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :chain_business_management,
    adapter: Ecto.Adapters.Tds
end
