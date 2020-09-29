defmodule ChainBusinessManagementWeb.Api.V1.AccountControllerTest do
  use ChainBusinessManagementWeb.ConnCase

  describe "create account" do
    @valid_params %{
      account: %{
        account_balance: 42,
        account_initial_balance: 42,
        account_initial_balance_datetime: "2020-07-19T12:00:00Z",
        account_number: "123",
        account_type: "2",
        clabe: "123456789123456789",
        company_number: "5483847",
        name: "Banamaexs base",
        user_id: "7488a646-e31f-11e4-aace-600308960662",
        bank_code: "002"
      }
    }

    @invalid_params %{
      account: %{account_balance: 42, account_initial_balance: 42, bank_code: "002"}
    }
    @invalid_params_no_bank %{account: %{}}

    test "with invalid params returns 422", %{conn: conn} do
      conn = post(conn, Routes.account_path(conn, :create), @invalid_params)

      assert json_response(conn, 422)
    end

    test "with non valid bank_code returns 422", %{conn: conn} do
      conn = post(conn, Routes.account_path(conn, :create), @invalid_params_no_bank)

      assert json_response(conn, 422)
    end

    test "with valid params retuns 200", %{conn: conn} do
      conn = post(conn, Routes.account_path(conn, :create), @valid_params)

      assert %{
               "id" => _id,
               "account_balance" => "42.00",
               "account_initial_balance" => "42.00",
               "account_initial_balance_datetime" => "2020-07-19T12:00:00Z",
               "account_number" => "123",
               "account_type" => 2,
               "branch_number" => nil,
               "clabe" => "123456789123456789",
               "company_number" => 5_483_847,
               "name" => "Banamaexs base",
               "user_id" => "7488a646-e31f-11e4-aace-600308960662",
               "bank" => %{
                 "id" => id,
                 "code" => "002",
                 "logo" => "Citibanamex",
                 "name" => "Citibanamex"
               }
             } = json_response(conn, 200)["data"]
    end
  end

  describe "update account" do
    @invalid_params %{account: %{clabe: 112_378_978_978_979_879_878_897_984}}

    test "with invalid params returns 422", %{conn: conn} do
      account = account_fixture()
      conn = patch(conn, Routes.account_path(conn, :update, account.id), @invalid_params)

      assert json_response(conn, 422)
    end

    test "with valid params returns 200", %{conn: conn} do
      account = account_fixture()
      params = %{account: %{name: "updated_name", account_number: "123"}}
      conn = patch(conn, Routes.account_path(conn, :update, account.id), params)

      assert %{
               "id" => _id,
               "account_balance" => "42.00",
               "account_initial_balance" => "42.00",
               "account_initial_balance_datetime" => _,
               "account_number" => "123",
               "account_type" => 2,
               "branch_number" => 42,
               "clabe" => "123456789123456789",
               "company_number" => 42,
               "name" => "updated_name",
               "user_id" => "7488a646-e31f-11e4-aace-600308960662",
               "bank" => %{
                 "id" => id,
                 "code" => "002",
                 "logo" => "Citibanamex",
                 "name" => "Citibanamex"
               }
             } = json_response(conn, 200)["data"]
    end
  end
end
