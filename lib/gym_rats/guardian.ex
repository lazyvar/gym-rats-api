defmodule GymRats.Guardian do
  alias GymRats.Model.Account
  alias GymRats.Repo
  alias Plug.Conn
  
  import Logger
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  @behaviour Plug

  def init([]), do: []

  def call(conn, []) do
    token = conn |> get_req_header("authorization") |> List.first

    case GymRats.Token.verify_and_validate(token) do
      {:ok, claims} -> assign(conn, :account, Account |> Repo.get(claims["user_id"]))
      {:error, _} -> json(conn, %{status: "fail", data: "Go away."}) |> halt
    end
  end
end

