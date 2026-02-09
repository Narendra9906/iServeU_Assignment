defmodule Isupayx.Idempotency.Handler do
  import Plug.Conn

  def check_idempotency(conn, _params) do
    case get_req_header(conn, "idempotency-key") do
      [] -> {:ok, :no_idempotency}
      [_key] -> {:ok, :accepted}
    end
  end
end
