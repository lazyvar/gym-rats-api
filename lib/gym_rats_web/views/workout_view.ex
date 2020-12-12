defmodule GymRatsWeb.WorkoutView do
  import GymRatsWeb.JSONView

  alias GymRatsWeb.{AccountView, WorkoutMediumView}

  @default_attrs ~w(
    id gym_rats_user_id created_at challenge_id title steps points occurred_at
    steps calories description distance duration google_place_id photo_url
    apple_device_name apple_source_name apple_workout_uuid activity_type
  )a

  @safe_activity_types ~w(walking running cycling hiit yoga hiking other)

  def default(workouts) when is_list(workouts) do
    workouts |> Enum.map(fn w -> default(w) end)
  end

  def default(workout) do
    workout
    |> keep(@default_attrs)
    |> safeguard_activity_type
  end

  def with_account_and_media(workouts) when is_list(workouts) do
    workouts |> Enum.map(fn w -> with_account_and_media(w) end)
  end

  def with_account_and_media(workout) do
    workout =
      workout
      |> keep([:account, :media | @default_attrs])
      |> safeguard_activity_type

    account = AccountView.default(Map.get(workout, :account))
    media = WorkoutMediumView.default(Map.get(workout, :media))

    workout
    |> Map.put(:account, account)
    |> Map.put(:media, media)
  end

  def safeguard_activity_type(workout) do
    activity_type = workout[:activity_type]

    case activity_type do
      nil ->
        workout

      _ ->
        safe_activity =
          @safe_activity_types
          |> Enum.find("other", fn activity -> activity == activity_type end)

        workout
        |> Map.put(:activity_type, safe_activity)
        |> Map.put(:activity_type_version_two, activity_type)
    end
  end
end
