defmodule ChainBusinessManagement.Repo do
  use Ecto.Repo,
    otp_app: :chain_business_management,
    adapter: Ecto.Adapters.Postgres
end
