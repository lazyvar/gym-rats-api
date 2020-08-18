defmodule GymRatsWeb.EmailController do
  use GymRatsWeb, :controller

  alias GymRats.Model.{Account}

  def unsubscribe(conn, params) do
    email = params["email"]

    if email == nil do
      text(conn, "Missing email.")
    else
      account = Account |> Repo.get_by(email: email)

      if account == nil do
        text(conn, "Email does not match existing account.")
      else
        account
        |> Account.changeset(%{subscribed: false})
        |> Repo.update()

        html(conn, "Unsubscribe successful. Click <a href=\"https://www.gymratsapi.com/subscribe?email=#{email}\" >here</a> to resubscribe.")
      end
    end
  end

  def subscribe(conn, params) do
    email = params["email"]

    if email == nil do
      text(conn, "Missing email.")
    else
      account = Account |> Repo.get_by(email: email)

      if account == nil do
        text(conn, "Email does not match existing account.")
      else
        account
        |> Account.changeset(%{subscribed: false})
        |> Repo.update()

        html(conn, "Subscribe successful. Click <a href=\"https://www.gymratsapi.com/unsubscribe?email=#{email}\" >here</a> to unsubscribe.")
      end
    end
  end
end
