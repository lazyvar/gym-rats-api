defmodule GymRatsWeb.AccountSettingsController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.Account
  alias GymRatsWeb.AccountSettingsView
  alias GymRats.Repo

  def show(conn, _params, account_id) do
    account = Account |> Repo.get!(account_id)

    success(conn, AccountSettingsView.default(account))
  end
end
