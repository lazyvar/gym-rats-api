defmodule GymRats.Guardian do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  @behaviour Plug

  def init([]), do: []

  def call(conn, []) do
    token = conn |> get_req_header("authorization") |> List.first()

    case GymRats.Token.verify_and_validate(token) do
      {:ok, claims} -> assign(conn, :account_id, claims["user_id"])
      {:error, _} -> json(conn, %{status: "fail", data: "Go away."}) |> halt
    end
  end
end
