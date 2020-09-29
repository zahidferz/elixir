defmodule ChainBusinessManagementWeb.Api.V1.OperationController do
  use ChainBusinessManagementWeb, :controller

  alias ChainBusinessManagement.Accounts
  alias ChainBusinessManagement.Utils
  alias ChainBusinessManagementWeb.ErrorView
  alias ChainBusinessManagementWeb.Schemas

  alias ChainBusinessManagementWeb.Schemas.Api.V1.{OperationControllerSchema}

  require Logger

  action_fallback ChainBusinessManagementWeb.Api.V1.FallbackController

  def create(conn, %{"user_id" => user_id, "operation" => operation_params}) do
    with {:ok, operation_params} <-
           Schemas.validate_schema(OperationControllerSchema, operation_params),
         account <- Accounts.get_account_by_user_id(user_id),
         operation_params <- build_operation_params(operation_params, account.id),
         {:ok, operation} <- Accounts.create_account_operation(operation_params) do
      operation = Accounts.preload_account_operation_type_and_status(operation)
      render(conn, "show.json", operation: operation)
    else
      {:error, "operation_type not found"} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ErrorView)
        |> render("invalid_enum.json",
          field: "operation_type",
          value: "#{operation_params["operation_type"]}"
        )

      {:error, "operation_status not found"} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ErrorView)
        |> render("invalid_enum.json",
          field: "operation_status",
          value: "#{operation_params["operation_status"]}"
        )

      err ->
        Logger.info("#{inspect(err)}")
        err
    end
  end

  def create(conn, %{
        "sale_id" => sale_id,
        "sale_datetime" => sale_datetime,
        "user_id" => user_id,
        "operations" => operations_params
      }) do
    with {:ok, operations_params} <-
           Schemas.validate_schemas(OperationControllerSchema, operations_params),
         account <- Accounts.get_account_by_user_id(user_id),
         operations_params <-
           Enum.map(operations_params, &build_operation_params(&1, account.id)),
         {:ok, result} <- Accounts.bulk_operations(sale_id, sale_datetime, operations_params) do
      render(conn, "index.json", operations: filter_entries_by_type(:operation, result))
    end
  end

  @spec build_operation_params(map(), pos_integer()) :: map()
  defp build_operation_params(params, account_id) do
    {:ok, operation_type} = Accounts.get_operation_type_by_name(params.operation_type)
    {:ok, operation_status} = Accounts.get_operation_status_by_name(params.operation_status)
    {:ok, datetime} = Timex.parse(params.operation_datetime, "{ISO:Extended}")
    offset = datetime.zone_abbr
    time_zone = datetime.time_zone
    amount = Utils.to_money(params.amount)

    %{
      account_id: account_id,
      amount: amount,
      client_id: params.client_id,
      company_number: params.company_number,
      currency: params.currency,
      operation_datetime: datetime,
      time_zone: time_zone,
      tz_offset: offset,
      account_operation_status_id: operation_status.id,
      account_operation_type_id: operation_type.id
    }
  end

  @spec filter_entries_by_type(atom(), map()) :: list()
  defp filter_entries_by_type(:operation, entries) do
    entries
    |> Enum.reduce([], fn {{key, _}, value}, acc ->
      case key do
        :operation -> [value | acc]
        _ -> acc
      end
    end)
    |> Enum.map(&Accounts.preload_account_operation_type_and_status/1)
  end
end
