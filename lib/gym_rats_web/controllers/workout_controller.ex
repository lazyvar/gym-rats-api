defmodule GymRatsWeb.WorkoutController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.Workout
  alias GymRats.Model.Challenge
  alias GymRats.Query.ChallengeQuery
  alias GymRats.Repo
  
  import Ecto.Query
  import Logger

  def create(conn, params, account_id) do 
    {challenges, params} = params |> Map.pop("challenges")
    challenge_filter = case challenges do
      nil -> &ChallengeQuery.all/1
      _ -> fn (c) -> c |> where([c], c.id in ^challenges) end
    end

    workouts = Challenge
    |> join(:left, [c], m in assoc(c, :memberships))
    |> where([_, m], m.gym_rats_user_id == ^account_id)
    |> challenge_filter.()
    |> ChallengeQuery.active
    |> Repo.all
    |> Enum.map(fn (c) -> %Workout{challenge_id: c.id, gym_rats_user_id: account_id} |> Workout.changeset(params) |> Repo.insert! end)

    success(conn, workouts |> List.first)
  end
end
