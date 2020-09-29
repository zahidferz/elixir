defmodule ChainBusinessManagement.Utils do
  @moduledoc """
  Contains operations to manipulate data
  """
  alias ChainBusinessManagement.Utils.Parsers

  @doc """
  Given a float or an integer, returns it's representation in `%Money{}` structure

    ## Examples
    iex> to_money(123.45)
    %Money{amount: 12345, currency: :MXN}

    iex> to_money(123)
    %Money{amount: 12300, currency: :MXN}
  """
  @spec to_money(float | integer) :: Money.t()
  def to_money(amount) when is_integer(amount), do: Parsers.integer_to_money(amount)
  def to_money(amount) when is_float(amount), do: Parsers.float_to_money(amount)

  @doc """
  Given a datetime, returns his offset and time_zone

    ## Examples
    iex> get_datetime_time_zone_and_offset(#DateTime<2020-03-03 12:00:00-05:00 -05 Etc/GMT+5>)
    {"-05", "Etc/GMT+5"}

    iex> get_datetime_time_zone_and_offset(~U[2020-03-03 12:00:00Z])
    {0, "Etc/UTC"}
  """
  @spec get_datetime_time_zone_and_offset(DateTime.t()) :: {String.t() | 0, String.t()}
  def get_datetime_time_zone_and_offset(%DateTime{} = datetime) do
    offset = if datetime.zone_abbr == "UTC", do: 0, else: datetime.zone_abbr

    {offset, datetime.time_zone}
  end
end
