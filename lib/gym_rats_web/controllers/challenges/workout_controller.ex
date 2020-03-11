defmodule GymRatsWeb.Challenge.WorkoutController do
  use GymRatsWeb, :protected_controller

  alias GymRatsWeb.WorkoutView
  alias GymRats.Model.Workout
  alias GymRats.Repo

  import Ecto.Query

  def index(conn, %{"challenge_id" => challenge_id}, _account_id) do
    challenge_id = String.to_integer(challenge_id)

    workouts =
      Workout
      |> join(:left, [w], c in assoc(w, :challenge))
      |> where([w, c], w.challenge_id == ^challenge_id)
      |> preload(:account)
      |> Repo.all()

    success(conn, WorkoutView.with_account(workouts))
  end

  def index(conn, _params, _account_id), do: failure(conn, "Missing challenge id.")
end
