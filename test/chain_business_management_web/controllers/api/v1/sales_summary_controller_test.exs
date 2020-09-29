defmodule ChainBusinessManagementWeb.Api.V1.SalesSummaryControllerTest do
  @moduledoc false
  use ChainBusinessManagementWeb.ConnCase

  describe "get sales for a company number and year" do
    test "with an existent company account with sales returns results", %{conn: conn} do
      company_number_test = 209_250

      account = account_fixture(%{company_number: company_number_test})

      account_operation =
        account_operation_fixture(%{
          account_id: account.id,
          company_number: account.company_number
        })

      sale_account_operation_fixture(%{
        account_operation_id: account_operation.id
      })

      conn =
        conn
        |> put_req_header("company_number", "#{company_number_test}")
        |> put_req_header("year", "2020")

      conn = get(conn, Routes.sales_summary_path(conn, :monthly_sales))

      assert %{
               "total" => "5.00",
               "months" => [
                 %{"total" => "5.00", "month" => 8, "currency" => "MXN"}
               ]
             } = json_response(conn, 200)["data"]
    end

    test "returns empty months and 0 total for a company with no sales in a given year", %{
      conn: conn
    } do
      company_number_test = 209_251

      account = account_fixture(%{company_number: company_number_test})

      account_operation =
        account_operation_fixture(%{
          account_id: account.id,
          company_number: account.company_number
        })

      sale_account_operation_fixture(%{
        account_operation_id: account_operation.id
      })

      conn =
        conn
        |> put_req_header("company_number", "#{company_number_test}")
        |> put_req_header("year", "2019")

      conn = get(conn, Routes.sales_summary_path(conn, :monthly_sales))

      assert %{
               "total" => "0.00",
               "months" => []
             } = json_response(conn, 200)["data"]
    end
  end

  describe "get years that have sales for a company or client" do
    test "returns 2 years results for a company number", %{conn: conn} do
      company_number_test = 209_252
      account = account_fixture(%{company_number: company_number_test})

      account_op_1 =
        account_operation_fixture(%{
          account_id: account.id,
          company_number: account.company_number
        })

      sale_account_operation_fixture(%{
        account_operation_id: account_op_1.id
      })

      account_op_2 =
        account_operation_fixture(%{
          account_id: account.id,
          company_number: account.company_number
        })

      sale_account_operation_fixture(%{
        sale_datetime: "2019-08-25T12:01:01",
        account_operation_id: account_op_2.id
      })

      conn =
        conn
        |> put_req_header("company_number", "#{company_number_test}")

      conn = get(conn, Routes.sales_summary_path(conn, :year_sales))

      assert %{
               "data" => [2020, 2019]
             } = json_response(conn, 200)
    end

    test "returns 0 years results for a company number", %{conn: conn} do
      company_number_test = 209_253
      account_fixture(%{company_number: company_number_test})

      conn =
        conn
        |> put_req_header("company_number", "#{company_number_test}")

      conn = get(conn, Routes.sales_summary_path(conn, :year_sales))

      assert %{
               "data" => []
             } = json_response(conn, 200)
    end

    test "returns 2 years results for a client id", %{conn: conn} do
      company_number_test = 209_254
      client_id_test = "d7dbab4c-039d-4052-a059-0718d4d4a775"
      account = account_fixture(%{company_number: company_number_test})

      account_op_1 =
        account_operation_fixture(%{
          account_id: account.id,
          company_number: account.company_number
        })

      sale_account_operation_fixture(%{
        account_operation_id: account_op_1.id
      })

      account_op_2 =
        account_operation_fixture(%{
          account_id: account.id,
          company_number: account.company_number
        })

      sale_account_operation_fixture(%{
        sale_datetime: "2019-08-25T12:01:01",
        account_operation_id: account_op_2.id
      })

      conn =
        conn
        |> put_req_header("client_id", "#{client_id_test}")

      conn = get(conn, Routes.sales_summary_path(conn, :year_sales))

      assert %{
               "data" => [2020, 2019]
             } = json_response(conn, 200)
    end

    test "returns 0 years results for a client id", %{conn: conn} do
      client_id_test = "a5dcba2a-039d-4052-a059-0718d4d4a775"
      company_number_test = 209_255
      account_fixture(%{company_number: company_number_test})

      conn =
        conn
        |> put_req_header("client_id", "#{client_id_test}")

      conn = get(conn, Routes.sales_summary_path(conn, :year_sales))

      assert %{
               "data" => []
             } = json_response(conn, 200)
    end
  end
end
