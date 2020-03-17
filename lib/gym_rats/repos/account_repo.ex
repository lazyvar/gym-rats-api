defmodule GymRats.Repo.AccountRepo do
  import Ecto.Query, only: [where: 3]

  alias GymRats.Repo
  alias GymRats.Model.Account

  def find_by_email(email) do
    Account
    |> where([a], a.email == ^email)
    |> Repo.one()
  end

  def challenges(account) do
    account
    |> Repo.preload(:challenges)
    |> Map.get(:challenges)
  end

  def exists?(token: token) do
    Account
    |> where([a], a.reset_password_token == ^token)
    |> Repo.exists?()
  end

  def find_by(reset_password_token: reset_password_token) do
    Account
    |> where([a], a.reset_password_token == ^reset_password_token)
    |> Repo.one()
  end
end
