defmodule GymRatsWeb.WorkoutView do
  import GymRatsWeb.JSONView

  @default_attrs ~w(id name code profile_picture_url start_date end_date)a

  def default(challenge) do
    challenge |> keep(@default_attrs)
  end
end
