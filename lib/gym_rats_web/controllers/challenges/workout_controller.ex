defmodule GymRatsWeb.Challenge.WorkoutController do
  use GymRatsWeb, :protected_controller

  alias GymRatsWeb.WorkoutView
  alias GymRats.Model.Workout
  alias GymRats.Repo

  require Logger

  import Ecto.Query

  def index(conn, %{"challenge_id" => challenge_id} = params, _account_id) do
    challenge_id = String.to_integer(challenge_id)

    workouts =
      Workout
      |> join(:left, [w], c in assoc(w, :challenge))
      |> where([w, c], w.challenge_id == ^challenge_id)
      |> paginate(params["page"])
      |> order_by(desc: :created_at)
      |> preload(:account)
      |> Repo.all()

    success(conn, WorkoutView.with_account(workouts))
  end

  def index(conn, _params, _account_id), do: failure(conn, "Missing challenge id and page.")

  defp paginate(query, page) do
    case Integer.parse(page || "") do
      {p, _} -> query |> offset(40 * ^p) |> limit(40)
      _ -> query
    end
  end
end
