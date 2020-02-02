defmodule GymRatsWeb.WorkoutView do
  import GymRatsWeb.JSONView

  @default_attrs ~w(gym_rats_user_id challenge_id title steps points steps calories description distance duration google_place_id photo_url)a

  def default(workout) do
    workout |> keep(@default_attrs)
  end
end
