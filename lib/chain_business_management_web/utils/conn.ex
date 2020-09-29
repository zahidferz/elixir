defmodule ChainBusinessManagementWeb.Api.V1.Utils.ConnUtils do
  @moduledoc """
    Utils to interact with Plug.conn struct
  """

  @doc """
   Transforms request headers specified by a list
   from a Plug.Conn.t() to a map

     ## Examples

      iex> headers_to_map(conn, ["user_id"])
      %{"user_id" => "852cc8a9-7b95-473e-b5a3-0f816e734cbc"}

      iex> headers_to_map(conn, ["users"])
      %{}
  """
  @spec headers_to_map(Plug.Conn.t(), list(String.t())) :: map()
  def headers_to_map(%Plug.Conn{} = conn, only_params) do
    map_headers =
      conn.req_headers
      |> Enum.into(%{})

    only_params
    |> Enum.reduce(%{}, fn param, acc ->
      case Map.fetch(map_headers, param) do
        {:ok, value} -> Map.put(acc, param, value)
        :error -> acc
      end
    end)
  end

  @doc """
   Transforms all request headers from Plug.conn to a map

    ## Examples

      iex> headers_to_map(conn)
      %{
        "accept" => "*/*",
        "accept-encoding" => "gzip, deflate, br",
        "cache-control" => "no-cache",
        "connection" => "keep-alive",
        "host" => "localhost:4004",
        "postman-token" => "0fcc6af2-4317-49b0-8f6d-40673c6fb1e3",
        "user-agent" => "PostmanRuntime/7.26.3",
      }
  """
  @spec headers_to_map(Plug.Conn.t()) :: map()
  def headers_to_map(%Plug.Conn{} = conn) do
    conn.req_headers
    |> Enum.into(%{})
  end
end
