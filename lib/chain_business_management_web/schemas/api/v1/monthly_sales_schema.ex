defmodule ChainBusinessManagementWeb.Schemas.Api.V1.MonthlySalesSchema do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :client_id,
    :company_number,
    :year
  ]

  embedded_schema do
    field :company_number, :integer
    field :client_id, Ecto.UUID
    field :year, :integer
  end

  def changeset(%{"company_number" => _company_number} = params) do
    %__MODULE__{}
    |> cast(params, [:company_number, :year])
    |> validate_required([:company_number, :year])
    |> validate_number(:year, greater_than: 0)
    |> validate_number(:company_number, greater_than: 0)
  end

  def changeset(%{"client_id" => _client_id} = params) do
    %__MODULE__{}
    |> cast(params, [:client_id, :year])
    |> validate_required([:client_id, :year])
    |> validate_number(:year, greater_than: 0)
    |> validate_number(:client_id, greater_than: 0)
  end

  def changeset(%{} = params) do
    %__MODULE__{}
    |> cast(params, @fields)
    |> validate_required(:company_number)
    |> validate_number(:company_number, greater_than: 0)
  end
end
