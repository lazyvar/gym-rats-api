defmodule GymRatsWeb.Open.AccountController do
  use GymRatsWeb, :controller

  alias GymRats.Model.Account

  def create(conn, params) do
    illegal_params = ~w(id created_at updated_at password_digest reset_password_token reset_password_token_expiration)
    params = params |> Map.drop(illegal_params)
    changeset = Account.registration_changeset(params)

    case Repo.insert(changeset) do
      {:ok, account} -> success(conn, account |> Account.with_token)
      {:error, e} -> failure(conn, "Uh oh")
    end
  end
end
