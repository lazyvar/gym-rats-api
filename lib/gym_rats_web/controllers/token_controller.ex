defmodule GymRatsWeb.TokenController do
  use GymRatsWeb, :controller

  alias GymRats.Model.Account
  alias GymRats.Repo.AccountRepo

  def create(conn, %{"email" => email, "password" => password}) do
    account = AccountRepo.find_by_email(email)

    cond do
      account == nil ->
        failure(conn, "Uh oh")
      Bcrypt.verify_pass(password, account.password_digest) ->
        success(conn, account |> Account.with_token)
      true ->
        failure(conn, "That email and password combination did not work")
    end
  end
end