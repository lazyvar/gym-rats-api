defmodule GymRats.Guardian do
  alias GymRats.Model.Account
  alias GymRats.Repo
  alias Plug.Conn
  
  import Logger
  import Plug.Conn

  @behaviour Plug

  def init([]), do: []

  def call(conn, []) do
    token = conn |> get_req_header("authorization") |> List.first
    
    case GymRats.Token.verify_and_validate(token) do
      {:ok, claims} -> assign(conn, :account, Account |> Repo.get(claims["user_id"]))
      {:error, _a} -> conn
    end

    # case Authenticator.find_user(conn) do
    #   {:ok, user} ->
    #     assign(conn, :user, user)
    #   :error ->
    #     conn |> put_flash(:info, "You must be logged in") |> redirect(to: "/") |> halt()
    # end
  end
end