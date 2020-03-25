defmodule GymRatsWeb.Open.PasswordController do
  use GymRatsWeb, :controller

  alias GymRats.Model.Account
  alias GymRats.Repo.AccountRepo
  alias GymRats.{Mailer, Random}

  import Ecto.Query

  def create(conn, %{"email" => email}) do
    account = Account |> where([a], a.email == ^email) |> Repo.one()

    case account do
      nil ->
        failure(conn, "An account with that email does not exist.")

      _ ->
        token = generate_token()
        expiration = DateTime.utc_now() |> DateTime.add(1_800, :second)
        update = %{reset_password_token: token, reset_password_token_expiration: expiration}
        account = account |> Account.changeset(update) |> Repo.update()

        case account do
          {:ok, account} ->
            account
            |> GymRats.Mail.ResetPassword.email(token)
            |> Mailer.deliver_later()

            success(conn, %{})

          {:error, account} ->
            failure(conn, account)
        end
    end
  end

  def create(conn, _params), do: failure(conn, "Missing email.")

  def update(conn, %{"id" => token, "password" => password}) do
    account = AccountRepo.find_by(reset_password_token: token)

    case account do
      nil ->
        failure(conn, "Token expired.")

      _ ->
        case DateTime.compare(DateTime.utc_now(), account.reset_password_token_expiration) do
          :gt ->
            failure(conn, "Token expired.")

          :lt ->
            update = %{
              reset_password_token: nil,
              reset_password_token_expiration: nil,
              password: password
            }

            account = account |> Account.registration_changeset(update) |> Repo.update()

            case account do
              {:ok, _} -> success(conn, %{})
              {:error, account} -> failure(conn, account)
            end
        end
    end
  end

  def update(conn, _params), do: failure(conn, "Missing params.")

  defp generate_token do
    token = Random.random_string(16)

    unless AccountRepo.exists?(token: token) do
      token
    else
      generate_token()
    end
  end
end
