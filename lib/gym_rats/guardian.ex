defmodule GymRats.Guardian do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]
  import GymRatsWeb.Rendering

  @behaviour Plug

  def init([]), do: []

  def call(conn, []) do
    token = conn |> get_req_header("authorization") |> List.first()

    case token do
      nil ->
        json(conn |> put_status(401), %{status: "failure", error: "Go away."}) |> halt

      _ ->
        case GymRats.Token.verify_and_validate(token) do
          {:ok, claims} ->
            assign(conn, :account_id, claims["user_id"])

          {:error, _} ->
            json(conn |> put_status(401), %{status: "failure", error: "Go away."}) |> halt
        end
    end
  end
end
