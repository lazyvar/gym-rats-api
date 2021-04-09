defmodule GymRatsWeb.Challenge.Member.WorkoutController do
  use GymRatsWeb, :protected_controller

  alias GymRatsWeb.WorkoutView
  alias GymRats.Model.{Workout, WorkoutMedium}

  import Ecto.Query

  def index(conn, %{"member_id" => member_id, "challenge_id" => challenge_id}, _) do
    workouts =
      Workout
      |> where([w], w.gym_rats_user_id == ^member_id and w.challenge_id == ^challenge_id)
      |> preload([:account, media: ^from(m in WorkoutMedium, order_by: [asc: m.id])])
      |> Repo.all()

    success(conn, WorkoutView.with_account_and_media(workouts))
  end
end
