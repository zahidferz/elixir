defmodule ChainBusinessManagementWeb.Schemas.Api.V1.SalesCompanyOperationSchema do
  @moduledoc """
  Contains schemas and functions to validate metric endpoint
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ChainBusinessManagementWeb.Schemas.Api.V1.SalesCompanyOperationSchema

  @fields [
    :company_number,
    :from,
    :to
  ]
  @required_fields [
    :company_number
  ]

  embedded_schema do
    field :company_number, :integer
    field :from, :date
    field :to, :date
  end

  def changeset(params \\ %{}) do
    %SalesCompanyOperationSchema{}
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> validate_date_range
  end

  defp validate_date_range(changeset) do
    from = get_field(changeset, :from)
    to = get_field(changeset, :to)

    if from && to do
      case Date.compare(from, to) do
        :gt -> add_error(changeset, :from, "Cannot be later than 'to'")
        _ -> changeset
      end
    else
      changeset
    end
  end
end
