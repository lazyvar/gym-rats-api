defmodule GymRatsWeb.Challenge.MemberController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.Account
  alias GymRats.Repo

  import Ecto.Query
  
  def index(conn, %{"challenge_id" => challenge_id}, account_id) do
    challenge_id = String.to_integer(challenge_id)
    members = Account 
    |> join(:left, [a], c in assoc(a, :challenges)) 
    |> join(:left, [a, c], w in assoc(c, :workouts)) 
    |> where([a, c, w], w.gym_rats_user_id == a.id and w.challenge_id == ^challenge_id)
    |> preload(:workouts) 
    |> Repo.all

    success(conn, members)
  end

  def index(conn, _params, _account_id), do: failure(conn, "Missing challenge id.")
end
