defmodule GymRatsWeb.Challenge.WorkoutController do
  use GymRatsWeb, :protected_controller

  alias GymRatsWeb.WorkoutView
  alias GymRats.Model.Workout
  alias GymRats.Repo

  import Ecto.Query

  def index(conn, %{"challenge_id" => challenge_id, "page" => page}, _account_id) do
    page = String.to_integer(page)
    challenge_id = String.to_integer(challenge_id)

    workouts =
      Workout
      |> join(:left, [w], c in assoc(w, :challenge))
      |> where([w, c], w.challenge_id == ^challenge_id)
      |> offset(100 * ^page)
      |> limit(100)
      |> order_by(desc: :created_at)
      |> preload(:account)
      |> Repo.all()

    success(conn, WorkoutView.with_account(workouts))
  end

  def index(conn, _params, _account_id), do: failure(conn, "Missing challenge id and page.")
end
