defmodule GymRatsWeb.WorkoutView do
  import GymRatsWeb.JSONView

  alias GymRatsWeb.AccountView

  @default_attrs ~w(
    id gym_rats_user_id created_at challenge_id title steps points 
    steps calories description distance duration google_place_id photo_url
    apple_device_name apple_source_name apple_workout_uuid activity_type
  )a

  def default(workouts) when is_list(workouts) do
    workouts |> Enum.map(fn w -> default(w) end)
  end

  def default(workout) do
    workout |> keep(@default_attrs)
  end

  def with_account(workouts) when is_list(workouts) do
    workouts |> Enum.map(fn w -> with_account(w) end)
  end

  def with_account(workout) do
    workout = workout |> keep([:account | @default_attrs])

    Map.put(workout, :account, AccountView.default(Map.get(workout, :account)))
  end
end
