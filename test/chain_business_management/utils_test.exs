defmodule ChainBusinessManagement.UtilsTest do
  use ChainBusinessManagement.DataCase

  alias ChainBusinessManagement.Utils

  describe "to_money/1" do
    test "with invalid data type raise FunctionClauseError" do
      assert_raise FunctionClauseError, ~r/^no function clause matching/, fn ->
        Utils.to_money("100.00")
      end
    end

    test "with valid amount returns it's representation in a Money structure" do
      assert %Money{} = money = Utils.to_money(15_340)
      assert Money.to_string(money) == "$15,340.00"
    end
  end
end
