defmodule ChainBusinessManagementWeb.Api.V1.OperationControllerTest do
  use ChainBusinessManagementWeb.ConnCase

  describe "create operation" do
    @valid_params %{
      operation: %{
        "amount" => 2_500,
        "client_id" => "7488a646-e31f-11e4-aace-600308960662",
        "company_number" => 10_000,
        "currency" => "MXN",
        "operation_datetime" => "2020-02-20T13:30:00-05:00",
        "operation_type" => "income",
        "operation_status" => "received"
      }
    }

    @invalid_params %{
      operation: %{
        "amount" => 2500,
        "client_id" => "7488a646-e31f-11e4-aace-600308960662",
        "company_number" => 10_000,
        "currency" => "MXNN",
        "operation_datetime" => "2020-02-20T13:30:00-05:00",
        "operation_type" => "income",
        "operation_status" => "received"
      }
    }

    @bad_formed %{operation: %{}}

    test "with valid params retuns 200", %{conn: conn} do
      account = account_fixture()

      conn =
        post(conn, Routes.operation_path(conn, :create), %{
          user_id: account.user_id,
          operation: @valid_params.operation
        })

      assert %{
               "account_id" => _,
               "id" => _id,
               "amount" => "2,500.00",
               "branch_number" => nil,
               "client_id" => "7488a646-e31f-11e4-aace-600308960662",
               "company_number" => 10_000,
               "currency" => "MXN",
               "tz_offset" => -5,
               "operation_datetime" => "2020-02-20T18:30:00Z",
               "operation_status" => "received",
               "operation_type" => "income"
             } = json_response(conn, 200)["data"]
    end

    test "with body request bad formed, returns 400", %{conn: conn} do
      account = account_fixture()
      params = Enum.into(@bad_formed, %{user_id: account.user_id})
      conn = post(conn, Routes.operation_path(conn, :create), params)
      assert json_response(conn, 400)
    end

    test "with invalid params, returns 422", %{conn: conn} do
      account = account_fixture()
      params = Enum.into(@invalid_params, %{user_id: account.user_id})
      conn = post(conn, Routes.operation_path(conn, :create), params)
      assert json_response(conn, 422)
    end
  end

  describe "create bulk operation" do
    @valid_operations [
      %{
        "amount" => 2_500,
        "client_id" => "7488a646-e31f-11e4-aace-600308960662",
        "company_number" => 10_000,
        "currency" => "MXN",
        "operation_datetime" => "2020-02-20T13:30:00-05:00",
        "operation_type" => "income",
        "operation_status" => "received"
      },
      %{
        "amount" => 2_500,
        "client_id" => "7488a646-e31f-11e4-aace-600308960662",
        "company_number" => 10_000,
        "currency" => "MXN",
        "operation_datetime" => "2020-10-20T13:30:00-05:00",
        "operation_type" => "income",
        "operation_status" => "expected"
      }
    ]

    @invalid_operations [
      %{
        "amount" => 2_500,
        "client_id" => "7488a646-e31f-11e4-aace-600308960662",
        "company_number" => 10_000,
        "currency" => "MXNNNNNN",
        "operation_datetime" => "2020-02-20T13:30:00-05:00",
        "operation_type" => "income",
        "operation_status" => "expected"
      }
    ]

    @bad_request_params %{
      "sale_id" => "7488a646-e31f-11e4-aace-600308960662",
      "sale_datetime" => "2020-03-04T12:00:00Z",
      "operations" => [%{"bad" => "param"}]
    }

    test "with mal formed request, returns 400", %{conn: conn} do
      account = account_fixture()
      params = Enum.into(@bad_request_params, %{"user_id" => account.user_id})
      conn = post(conn, Routes.operation_path(conn, :create), params)
      assert json_response(conn, 400)
    end

    test "with invalid params, returns 422", %{conn: conn} do
      account = account_fixture()

      body = %{
        "user_id" => account.user_id,
        "sale_id" => "7488a646-e31f-11e4-aace-600308960662",
        "sale_datetime" => "2020-09-30T12:00:00Z",
        "operations" => @invalid_operations
      }

      conn = post(conn, Routes.operation_path(conn, :create), body)

      assert json_response(conn, 422)
    end

    test "with valid params, returns 200", %{conn: conn} do
      account = account_fixture()
      operations = Enum.map(@valid_operations, fn o -> Map.put(o, "account_id", account.id) end)

      body = %{
        "user_id" => account.user_id,
        "sale_id" => "7488a646-e31f-11e4-aace-600308960662",
        "sale_datetime" => "2020-09-30T12:00:00-05:00",
        "operations" => operations
      }

      conn = post(conn, Routes.operation_path(conn, :create), body)

      assert %{"data" => operations} = json_response(conn, 200)
      assert Enum.count(operations) == Enum.count(@valid_operations)
    end
  end
end
