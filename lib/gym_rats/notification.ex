defmodule GymRats.Notification do
  alias Pigeon.{APNS, FCM}
  alias GymRats.Model.{Workout, AndroidDevice, Device, Account, Challenge, ChatNotification}
  alias GymRats.Repo
  alias GymRatsWeb.Presence

  import Ecto.Query
  import Pigeon.APNS.Notification
  import Pigeon.FCM.Notification

  require Logger

  def send_workouts(workouts) do
    Task.async(fn -> send_workouts_sync(workouts) end)
  end

  defp send_workouts_sync(workouts) do
    workouts
    |> Repo.preload([:challenge, :account])
    |> Enum.flat_map(fn workout ->
      Account
      |> join(:left, [a], m in assoc(a, :memberships))
      |> where(
        [a, m],
        a.id == m.gym_rats_user_id and m.challenge_id == ^workout.challenge_id and
          a.id != ^workout.account.id
      )
      |> Repo.all()
      |> Enum.map(fn member ->
        {member, workout}
      end)
    end)
    |> Enum.uniq_by(fn {member, _} -> member.id end)
    |> Enum.map(fn {member, workout} ->
      payload = %{
        "workout_id" => workout.id,
        "notification_type" => "workout",
        "challenge_id" => workout.challenge_id
      }

      send_notification_to_account(
        workout.challenge.name,
        workout.account.full_name,
        workout.title,
        payload,
        member.id
      )
    end)
  end

  def send_chat_message(chat_message) do
    Task.async(fn -> send_chat_message_sync(chat_message) end)
  end

  defp send_chat_message_sync(chat_message) do
    challenge = Challenge |> Repo.get!(chat_message.challenge_id)

    payload = %{
      "challenge_id" => challenge.id,
      "notification_type" => "chat_message",
      "message_id" => chat_message.id
    }

    members =
      Account
      |> join(:left, [a], m in assoc(a, :memberships))
      |> where(
        [a, m],
        a.id == m.gym_rats_user_id and m.challenge_id == ^challenge.id and
          a.id != ^chat_message.account.id
      )
      |> Repo.all()

    notification_message =
      if chat_message.message_type == "image" do
        "Shared a photo"
      else
        chat_message.content
      end

    Enum.map(members, fn member ->
      if Presence.get_by_key("room:challenge:#{challenge.id}", "account:#{member.id}") == [] do
        send_notification_to_account(
          challenge.name,
          chat_message.account.full_name,
          notification_message,
          payload,
          member.id
        )
      end
    end)
  end

  def send_workout_comment(comment) do
    Task.async(fn -> send_workout_comment_sync(comment) end)
  end

  defp send_workout_comment_sync(comment) do
    workout = Workout |> preload(:account) |> Repo.get!(comment.workout_id)

    payload = %{
      "workout_id" => workout.id,
      "notification_type" => "workout_comment",
      "challenge_id" => workout.challenge_id
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

    Enum.map(talkers, fn talker ->
      send_notification_to_account(
        workout.title,
        comment.account.full_name,
        comment.content,
        payload,
        talker.id
      )
    end)

    if workout.account.id != comment.account.id do
      send_notification_to_account(
        workout.title,
        comment.account.full_name,
        comment.content,
        payload,
        workout.account.id
      )
    end
  end

  defp send_notification_to_account(title, subtitle, body, gr_payload, account_id) do
    Task.async(fn ->
      send_notification_to_account_sync(title, subtitle, body, gr_payload, account_id)
    end)
  end

  defp send_notification_to_account_sync(title, subtitle, body, gr_payload, account_id) do
    device = Device |> where([d], d.gym_rats_user_id == ^account_id) |> Repo.one()
    android_device = AndroidDevice |> where([d], d.account_id == ^account_id) |> Repo.one()
    account = Account |> Repo.get!(account_id)

    if device != nil && notification_type_enabled(gr_payload["notification_type"], account) do
      apns =
        APNS.Notification.new(%{}, device.token, "com.hasz.GymRats")
        |> put_alert(%{
          "title" => title,
          "subtitle" => subtitle,
          "body" => body
        })
        |> put_custom(%{"gr" => gr_payload})

      Pigeon.APNS.push(apns, on_response: fn response -> Logger.info(inspect(response)) end)
    end

    if android_device != nil &&
         notification_type_enabled(gr_payload["notification_type"], account) do
      notification =
        FCM.Notification.new(android_device.token)
        |> put_notification(%{
          "title" => title,
          "subtitle" => subtitle,
          "body" => body
        })
        |> put_data(%{"gr" => "gr_payload"})

      Pigeon.FCM.push(notification, on_response: fn response -> Logger.info(inspect(response)) end)
    end

    if gr_payload["notification_type"] == "chat_message" do
      %ChatNotification{}
      |> ChatNotification.changeset(%{
        seen: false,
        message_id: gr_payload["message_id"],
        account_id: account_id
      })
      |> Repo.insert!()
    end
  end

  defp notification_type_enabled(notification_type, account) do
    case notification_type do
      "workout_comment" -> account.comment_notifications_enabled
      "chat_message" -> account.chat_message_notifications_enabled
      "workout" -> account.workout_notifications_enabled
      _ -> false
    end
  end
end
