defmodule ChainBusinessManagementWeb.Api.V1.FallbackController do
  use ChainBusinessManagementWeb, :controller

  alias ChainBusinessManagementWeb.API.V1.ChangesetView

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, _, %Ecto.Changeset{} = changeset, _}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:bad_request, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:bad_request)
    |> put_view(ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, nil) do
    send_resp(conn, :no_content, "")
  end
end
