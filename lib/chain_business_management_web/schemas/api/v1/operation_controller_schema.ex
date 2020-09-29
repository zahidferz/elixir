defmodule ChainBusinessManagementWeb.Schemas.Api.V1.OperationControllerSchema do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :account_id,
    :amount,
    :client_id,
    :company_number,
    :currency,
    :operation_datetime,
    :operation_type,
    :operation_status
  ]
  @required_fields [:amount, :operation_datetime, :operation_type, :operation_status]

  @operation_type ["income", "expenses"]
  @operation_status ["received", "expected", "overdue", "cancelled"]

  embedded_schema do
    field :account_id, :integer
    field :amount, :float
    field :client_id, Ecto.UUID
    field :company_number, :integer
    field :currency, :string
    field :operation_datetime, :string
    field :operation_type, :string
    field :operation_status, :string
  end

  @spec changeset(:invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}) ::
          Ecto.Changeset.t()
  def changeset(attrs \\ %{}) do
    %__MODULE__{}
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:operation_type, @operation_type)
    |> validate_inclusion(:operation_status, @operation_status)
    |> validate_format(
      :operation_datetime,
      ~r/^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[01]|0[1-9]|[12][0-9])T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\\.[0-9]+)?(Z|((\+|\-)\d{2}:\d{2}))?$/,
      message: "Invalid format"
    )
  end
end
