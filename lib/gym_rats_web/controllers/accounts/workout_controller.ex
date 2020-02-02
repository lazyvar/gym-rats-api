defmodule GymRatsWeb.Account.WorkoutController do
  use GymRatsWeb, :protected_controller

  alias GymRatsWeb.WorkoutView
  alias GymRats.Model.Workout

  import Ecto.Query

  def index(conn, %{"account_id" => account_id}, _) do
    workouts = Workout |> where([w], w.gym_rats_user_id == ^account_id) |> Repo.all

    success(conn, WorkoutView.default(workouts))
  end
end