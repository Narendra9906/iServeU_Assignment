defmodule IsupayxWeb.TransactionController do
  use IsupayxWeb, :controller

  alias Isupayx.Transactions.Service

  def create(conn, params) do
    case Service.create_transaction(conn, params) do
      {:ok, status, response} ->
        conn
        |> put_status(status)
        |> json(response)

      {:error, status, error_response} ->
        conn
        |> put_status(status)
        |> json(error_response)
    end
  end
end
