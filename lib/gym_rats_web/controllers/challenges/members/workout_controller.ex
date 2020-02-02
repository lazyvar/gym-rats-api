defmodule GymRatsWeb.Challenge.Member.WorkoutController do
  use GymRatsWeb, :protected_controller

  alias GymRatsWeb.WorkoutView
  alias GymRats.Model.Workout

  import Ecto.Query

  def index(conn, %{"member_id" => member_id, "challenge_id" => challenge_id}, _) do
    workouts = Workout 
    |> where([w], w.gym_rats_user_id == ^member_id and w.challenge_id == ^challenge_id) 
    |> Repo.all

    success(conn, WorkoutView.default(workouts))
  end
end