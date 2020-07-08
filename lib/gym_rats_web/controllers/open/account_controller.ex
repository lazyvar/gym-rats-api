defmodule GymRatsWeb.Open.AccountController do
  use GymRatsWeb, :controller

  alias GymRatsWeb.AccountView
  alias GymRats.Model.Account

  def create(conn, params) do
    illegal_params =
      ~w(id created_at updated_at password_digest reset_password_token reset_password_token_expiration)

    params = params |> Map.drop(illegal_params)
    changeset = Account.registration_changeset(%Account{}, params)

    case Repo.insert(changeset) do
      {:ok, account} ->
        GymRats.TextMessage.send_signup_text_to_mack(account)
        account = account |> Account.put_token()
        success(conn, AccountView.for_current_user(account))

      {:error, account} ->
        failure(conn, account)
    end
  end
end
