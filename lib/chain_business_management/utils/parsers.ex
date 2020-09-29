defmodule ChainBusinessManagement.Utils.Parsers do
  @moduledoc """
  Contains functions to parse data to another struct with custom rules
  """

  @doc """
  Given a float number, returns it's representation in `Money` structure

    ## Examples
      iex> float_to_money(123.45)
      %Money{amount: 12345, currency: :MXN}
  """
  @spec float_to_money(float) :: Money.t()
  def float_to_money(amount) when is_float(amount) do
    amount
    |> :erlang.float_to_binary(decimals: 2)
    |> String.replace(".", "")
    |> String.to_integer(10)
    |> Money.new()
  end

  @doc """
  Given an integer number, returns it's representation in `Money` structure.

  Internally the function multiplies the amount by 100 in order to add the decimal part (cents).

    ## Examples
      iex> integer_to_money(1_245)
      %Money{amount: 12345, currency: :MXN}
  """
  @spec integer_to_money(integer) :: Money.t()
  def integer_to_money(amount) when is_integer(amount) do
    (amount * 100)
    |> Money.new()
  end
end
