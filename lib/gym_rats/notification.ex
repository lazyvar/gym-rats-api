defmodule GymRats.Notification do
  alias Pigeon.APNS
  alias GymRats.Model.{Workout, Device, Account}
  alias GymRats.Repo

  require Logger

  import Ecto.Query

  def send_workout_comment(comment) do
    workout = Workout |> preload(:account) |> Repo.get!(comment.workout_id)

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

    Enum.map(talkers, fn talker -> send_notification_to_account(alert, talker.id) end)

    if workout.account.id != comment.account.id do
      send_notification_to_account(alert, workout.account.id)
    end
  end

  defp send_notification_to_account(alert, account_id) do
    Task.async(fn -> send_notification_to_account_sync(alert, account_id) end)
  end

  defp send_notification_to_account_sync(alert, account_id) do
    device = Device |> where([d], d.gym_rats_user_id == ^account_id) |> Repo.one()

    if device != nil do
      apns = APNS.Notification.new(alert, device.token, "com.hasz.GymRats")
      Pigeon.APNS.push(apns)
    end
  end
end
