defmodule GymRatsWeb.AccountController do
  use GymRatsWeb, :controller

  alias GymRats.Model.Account

  def create(conn, params) do
    changeset = Account.registration_changeset(params)

    case Repo.insert(changeset) do
      {:ok, account} -> success(conn, account |> Account.with_token)
      {:error, _} -> failure(conn, "Uh oh")
    end
  end
end