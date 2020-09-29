defmodule ChainBusinessManagement.Utils.ParsersTest do
  use ChainBusinessManagement.DataCase

  alias ChainBusinessManagement.Utils.Parsers

  describe "float_to_money/1" do
    test "with not given float number raise an error" do
      assert_raise FunctionClauseError, ~r/^no function clause matching/, fn ->
        Parsers.float_to_money("100.00")
      end
    end

    test "with valid float number returns a money structure" do
      assert %Money{} = money = Parsers.float_to_money(20_453.23)
      assert Money.to_string(money) == "$20,453.23"
    end
  end

  describe "integer_to_money/1" do
    test "with not given integer number raise an error" do
      assert_raise FunctionClauseError, ~r/^no function clause matching/, fn ->
        Parsers.integer_to_money("100.00")
      end
    end

    test "with valid integer number returns a money structure" do
      assert %Money{} = money = Parsers.integer_to_money(20_453)
      assert Money.to_string(money) == "$20,453.00"
    end
  end
end
