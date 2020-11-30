defmodule GymRats.Factory do
  use ExMachina.Ecto, repo: GymRats.Repo

  def account_factory do
    %GymRats.Model.Account{
      full_name: "Joe Macdonald",
      email: sequence(:email, &"joe-#{&1}@example.com"),
      profile_picture_url: "instagram.com/i/c10s",
      password_digest: "$2b$12$dWtgcRccPr8pXdYEGKlWOeWJNmB9jYqLKZdsZxczI5zXVgwJUq6mW"
    }
  end

  def account_with_workouts_factory do
    struct!(
      account_factory(),
      %{
        workouts: build_list(3, :workout)
      }
    )
  end

  def workout_factory do
    %GymRats.Model.Workout{
      account: build(:account),
      challenge: build(:challenge),
      occurred_at: DateTime.utc_now,
      title: "Swoll.",
      description: "You already know.",
      steps: 1000,
      duration: 90,
      distance: "33.3",
      google_place_id: "x5134b1",
      photo_url: "firebase.com/pics/dfv9-12"
    }
  end

  def challenge_factory do
    %GymRats.Model.Challenge{
      name: "Challenge accepted!",
      code: sequence(:code, &"#{&1}#{&1}#{&1}#{&1}#{&1}#{&1}"),
      start_date: DateTime.utc_now() |> DateTime.truncate(:second),
      end_date: DateTime.utc_now() |> DateTime.truncate(:second),
      time_zone: "PST",
      profile_picture_url: "i.reddit.com/woop"
    }
  end

  def membership_factory do
    %GymRats.Model.Membership{
      account: build(:account),
      challenge: build(:challenge)
    }
  end

  def active_challenge_factory do
    struct!(
      challenge_factory(),
      %{
        start_date:
          DateTime.utc_now() |> DateTime.add(-1 * 60 * 60 * 60) |> DateTime.truncate(:second),
        end_date: DateTime.utc_now() |> DateTime.add(60 * 60 * 60) |> DateTime.truncate(:second)
      }
    )
  end

  def complete_challenge_factory do
    struct!(
      challenge_factory(),
      %{
        start_date:
          DateTime.utc_now() |> DateTime.add(-1 * 60 * 60 * 60) |> DateTime.truncate(:second),
        end_date:
          DateTime.utc_now() |> DateTime.add(-1 * 60 * 60 * 60) |> DateTime.truncate(:second)
      }
    )
  end

  def upcoming_challenge_factory do
    struct!(
      challenge_factory(),
      %{
        start_date:
          DateTime.utc_now() |> DateTime.add(60 * 60 * 60) |> DateTime.truncate(:second),
        end_date: DateTime.utc_now() |> DateTime.add(60 * 60 * 60) |> DateTime.truncate(:second)
      }
    )
  end

  def comment_factory do
    %GymRats.Model.Comment{
      content: "Nice calves!",
      account: build(:account),
      workout: build(:workout)
    }
  end

  def message_factory do
    %GymRats.Model.Message{
      content: "Hi."
    }
  end

  def chat_notification_factory do
    %GymRats.Model.ChatNotification{
      seen: false
    }
  end
end
