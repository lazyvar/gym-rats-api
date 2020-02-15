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
end
