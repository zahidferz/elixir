defmodule ChainBusinessManagementWeb.Api.V1.ReceivablesControllerTest do
  use ChainBusinessManagementWeb.ConnCase
  alias ChainBusinessManagement.Utils

  defp get_current_datetime_mx() do
    {:ok, date_time_now} = DateTime.now("Etc/GMT+5")
    date_time_now
  end

  describe "Company receivables controller" do
    test "returns 200", %{conn: conn} do
      account = account_fixture()
      conn = get(conn, Routes.receivables_path(conn, :index, account.company_number))

      assert %{"expected" => "$0.00", "overdue" => "$0.00", "today" => "$0.00"} =
               json_response(conn, 200)["data"]
    end
  end

  test "get company receivables with received operations", %{conn: conn} do
    company_number_test = 108_564
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

    conn = get(conn, Routes.receivables_path(conn, :index, company_number_test))

    assert %{"expected" => "$0.00", "overdue" => "$0.00", "today" => "$100.00"} =
             json_response(conn, 200)["data"]
  end
end
