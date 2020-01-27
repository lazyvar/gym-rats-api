defmodule GymRats.Guardian do
  use Guardian, otp_app: :gym_rats

  alias GymRats.Model.Account
  alias GymRats.Repo

  def subject_for_token(account, _claims) do
    sub = to_string(account.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    account = Account |> Repo.get(id)
    {:ok,  account}
  end
end