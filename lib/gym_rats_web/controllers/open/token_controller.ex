defmodule GymRatsWeb.Open.TokenController do
  use GymRatsWeb, :controller

  alias GymRatsWeb.AccountView
  alias GymRats.Model.Account
  alias GymRats.Repo.AccountRepo

  def create(conn, %{"email" => email, "password" => password}) do
    account = AccountRepo.find_by_email(email)

    cond do
      account == nil ->
        failure(conn, "That email and password combination did not work")

      Bcrypt.verify_pass(password, account.password_digest) ->
        success(conn, AccountView.for_current_user(account |> Account.put_token()))

      true ->
        failure(conn, "That email and password combination did not work")
    end
  end
end
