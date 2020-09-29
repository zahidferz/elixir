defmodule ChainBusinessManagementWeb.Schemas.Api.V1.YearSalesSchema do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :company_number,
    :client_id
  ]

  embedded_schema do
    field :company_number, :integer
    field :client_id, Ecto.UUID
  end

  def changeset(%{"company_number" => _company_number} = params) do
    %__MODULE__{}
    |> cast(params, @fields)
    |> validate_required(:company_number)
    |> validate_number(:company_number, greater_than: 0)
  end

  def changeset(%{"client_id" => _client_id} = params) do
    %__MODULE__{}
    |> cast(params, @fields)
    |> validate_required(:client_id)
  end

  def changeset(%{} = params) do
    %__MODULE__{}
    |> cast(params, @fields)
    |> validate_required(:company_number)
    |> validate_number(:company_number, greater_than: 0)
  end
end
