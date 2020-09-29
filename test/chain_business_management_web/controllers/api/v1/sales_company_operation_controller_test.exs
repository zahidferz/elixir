defmodule ChainBusinessManagementWeb.Api.V1.SalesCompanyOperationControllerTest do
  @moduledoc false
  use ChainBusinessManagementWeb.ConnCase

  alias ChainBusinessManagement.Utils

  defp get_current_datetime_mx() do
    {:ok, date_time_now} = DateTime.now("Etc/GMT+5")
    date_time_now
  end

  defp get_datetime_n_days_ago_mx(days) do
    Timex.now("Etc/GMT+5")
    |> Timex.shift(days: -days)
    |> Timex.to_datetime()
  end

  describe "get current day company operations" do
    test "returns a map with company and total amount", %{conn: conn} do
      company_number_test = 208_250

      account = account_fixture(%{company_number: company_number_test})

      datetime_now = get_current_datetime_mx()

      {offset, time_zone} = Utils.get_datetime_time_zone_and_offset(datetime_now)

      account_operation =
        account_operation_fixture(%{
          operation_datetime: datetime_now,
          tz_offset: offset,
          time_zone: time_zone,
          account_id: account.id,
          company_number: account.company_number
        })

      sale_account_operation_fixture(%{
        account_operation_id: account_operation.id,
        tz_offset: offset,
        time_zone: time_zone,
        sale_datetime: datetime_now
      })

      conn = get(conn, Routes.sales_company_operation_path(conn, :show, company_number_test))

      assert %{
               "amount_total" => "5.00",
               "company_number" => ^company_number_test
             } = json_response(conn, 200)["data"]
    end

    test "returns no content when no sales for the day", %{conn: conn} do
      company_number_test = 208_251

      account = account_fixture(%{company_number: company_number_test})

      account_operation =
        account_operation_fixture(%{
          account_id: account.id,
          company_number: account.company_number
        })

      sale_account_operation_fixture(%{account_operation_id: account_operation.id})

      # sales_company_operation_path
      conn = get(conn, Routes.sales_company_operation_path(conn, :show, company_number_test))

      assert response(conn, 204)
    end
  end

  describe "get company operations from a given past date range" do
    test "returns a map with company number and total amount for the given range", %{conn: conn} do
      company_number_test = 208_252

      account = account_fixture(%{company_number: company_number_test})

      past_datetime_from = get_datetime_n_days_ago_mx(5)

      {offset, time_zone} = Utils.get_datetime_time_zone_and_offset(past_datetime_from)

      account_operation =
        account_operation_fixture(%{
          operation_datetime: past_datetime_from,
          tz_offset: offset,
          time_zone: time_zone,
          account_id: account.id,
          company_number: account.company_number
        })

      sale_account_operation_fixture(%{
        account_operation_id: account_operation.id,
        tz_offset: offset,
        time_zone: time_zone,
        sale_datetime: past_datetime_from
      })

      past_date_from =
        DateTime.to_date(past_datetime_from)
        |> to_string()

      past_date_to =
        4
        |> get_datetime_n_days_ago_mx()
        |> DateTime.to_date()
        |> to_string()

      conn =
        get(
          conn,
          Routes.sales_company_operation_path(conn, :show, company_number_test, %{
            from: past_date_from,
            to: past_date_to
          })
        )

      assert %{
               "amount_total" => "5.00",
               "company_number" => ^company_number_test
             } = json_response(conn, 200)["data"]
    end

    test "returns no content when no sales for the given range", %{conn: conn} do
      company_number_test = 208_253

      account = account_fixture(%{company_number: company_number_test})

      past_datetime_from_operation = get_datetime_n_days_ago_mx(5)

      {offset, time_zone} = Utils.get_datetime_time_zone_and_offset(past_datetime_from_operation)

      account_operation =
        account_operation_fixture(%{
          operation_datetime: past_datetime_from_operation,
          tz_offset: offset,
          time_zone: time_zone,
          account_id: account.id,
          company_number: account.company_number
        })

      sale_account_operation_fixture(%{
        account_operation_id: account_operation.id,
        tz_offset: offset,
        time_zone: time_zone,
        sale_datetime: past_datetime_from_operation
      })

      past_date_from =
        17
        |> get_datetime_n_days_ago_mx()
        |> DateTime.to_date()
        |> to_string()

      past_date_to =
        15
        |> get_datetime_n_days_ago_mx()
        |> DateTime.to_date()
        |> to_string()

      conn =
        get(
          conn,
          Routes.sales_company_operation_path(conn, :show, company_number_test, %{
            from: past_date_from,
            to: past_date_to
          })
        )

      assert response(conn, 204)
    end
  end
end
