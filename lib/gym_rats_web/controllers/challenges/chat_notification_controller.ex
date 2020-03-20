defmodule GymRatsWeb.Challenge.ChatNotificationController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.ChatNotification
  alias GymRats.Repo

  import Ecto.Query

  def count(conn, %{"challenge_id" => challenge_id}, account_id) do
    challenge_id = String.to_integer(challenge_id)

    count =
      ChatNotification
      |> join(:left, [n], m in assoc(n, :message))
      |> where(
        [n, m],
        n.seen == false and n.account_id == ^account_id and m.challenge_id == ^challenge_id
      )
      |> select(count("*"))
      |> Repo.one()

    success(conn, %{count: count})
  end

  def seen(conn, %{"challenge_id" => challenge_id}, account_id) do
    challenge_id = String.to_integer(challenge_id)

    ChatNotification
    |> join(:inner, [n], m in assoc(n, :message))
    |> where([n, m], n.account_id == ^account_id and m.challenge_id == ^challenge_id)
    |> Repo.delete_all()

    success(conn, "👁️")
  end
end
