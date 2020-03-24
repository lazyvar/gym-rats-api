defmodule GymRatsWeb.Challenge.InfoController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.{Account, Workout}
  alias GymRats.Repo

  import Ecto.Query

  def info(conn, %{"challenge_id" => challenge_id}, account_id) do
    member_count =
      Account
      |> join(:left, [a], c in assoc(a, :memberships))
      |> where([a, m], a.id == m.gym_rats_user_id and m.challenge_id == ^challenge_id)
      |> select(count("*"))
      |> Repo.one()

    workout_count =
      Workout
      |> join(:left, [w], c in assoc(w, :challenge))
      |> where([w, c], w.challenge_id == ^challenge_id)
      |> select(count("*"))
      |> Repo.one()

    success(conn, %{member_count: member_count, workout_count: workout_count})
  end
end
