defmodule GymRats.Notification do
  alias Pigeon.APNS
  alias GymRats.Model.{Workout, Device, Account, Challenge}
  alias GymRats.Repo

  require Logger

  import Ecto.Query

  def send_chat_message(chat_message) do
    Task.async(fn -> send_chat_message_sync(chat_message) end)
  end

  def send_chat_message_sync(chat_message) do
    challenge = Challenge |> Repo.get!(chat_message.challenge_id)

    alert = %{
      "title" => challenge.name,
      "subtitle" => chat_message.account.full_name,
      "body" => chat_message.content
    }

    payload = %{"challenge_id" => challenge.id}

    peeps =
      Account
      |> join(:left, [a], m in assoc(a, :memberships))
      |> where(
        [a, m],
        a.id == m.gym_rats_user_id and m.challenge_id == ^challenge.id and
          a.id != ^chat_message.account.id
      )
      |> Repo.all()

    Enum.map(peeps, fn peep -> send_notification_to_account(alert, payload, peep.id) end)
  end

  def send_workout_comment(comment) do
    Task.async(fn -> send_workout_comment_sync(comment) end)
  end

  defp send_workout_comment_sync(comment) do
    workout = Workout |> preload(:account) |> Repo.get!(comment.workout_id)
    payload = %{"workout_id" => workout.id}

    alert = %{
      "title" => workout.title,
      "subtitle" => comment.account.full_name,
      "body" => comment.content
    }

    talkers =
      Account
      |> distinct(true)
      |> join(:left, [a], c in assoc(a, :comments))
      |> join(:left, [_, c], w in assoc(c, :workout))
      |> where(
        [a, c, w],
        a.id == c.gym_rats_user_id and c.workout_id == w.id and a.id != ^workout.account.id and
          a.id != ^comment.account.id and w.id == ^workout.id
      )
      |> Repo.all()

    Enum.map(talkers, fn talker -> send_notification_to_account(alert, payload, talker.id) end)

    if workout.account.id != comment.account.id do
      send_notification_to_account(alert, payload, workout.account.id)
    end
  end

  defp send_notification_to_account(alert, payload, account_id) do
    device = Device |> where([d], d.gym_rats_user_id == ^account_id) |> Repo.one()

    if device != nil do
      apns = APNS.Notification.new(alert, device.token, "com.hasz.GymRats")
      payload = apns.payload |> Map.put("gr", payload)
      apns = apns |> Map.put("payload", payload)

      Pigeon.APNS.push(apns)
    end
  end
end
