defmodule GymRatsWeb.AccountController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.Account
  alias GymRatsWeb.AccountView
  alias GymRats.Repo

  def update_self(conn, params, account_id) do
    account = Account |> Repo.get(account_id)

    illegal_params =
      ~w(id created_at updated_at password_digest password reset_password_token reset_password_token_expiration)

    params = params |> Map.drop(illegal_params)
    account = account |> Account.changeset(params) |> Repo.update()

    case account do
      {:ok, account} ->
        account = account |> Account.put_token()
        success(conn, AccountView.with_token(account))

      {:error, account} ->
        failure(conn, account)
    end
  end
end
