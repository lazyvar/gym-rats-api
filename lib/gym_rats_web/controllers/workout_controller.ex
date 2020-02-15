defmodule GymRatsWeb.WorkoutController do
  use GymRatsWeb, :protected_controller

  alias GymRatsWeb.WorkoutView
  alias GymRats.Model.{Workout, Challenge, Membership}
  alias GymRats.Query.ChallengeQuery
  alias GymRats.Repo

  import Ecto.Query

  def create(conn, params, account_id) do
    {challenges, params} = params |> Map.pop("challenges")

    challenge_filter =
      case challenges do
        nil -> &ChallengeQuery.all/1
        _ -> fn c -> c |> where([c], c.id in ^challenges) end
      end

    workouts =
      Challenge
      |> join(:left, [c], m in assoc(c, :memberships))
      |> where([_, m], m.gym_rats_user_id == ^account_id)
      |> challenge_filter.()
      |> ChallengeQuery.active()
      |> Repo.all()
      |> Enum.map(fn c ->
        %Workout{challenge_id: c.id, gym_rats_user_id: account_id}
        |> Workout.changeset(params)
        |> Repo.insert!()
      end)

    success(conn, WorkoutView.default(workouts |> List.first()))
  end

  def delete(conn, %{"id" => workout_id}, account_id) do
    workout_id = String.to_integer(workout_id)
    workout = Workout |> Repo.get(workout_id)

    case workout do
      nil ->
        failure(conn, "Workout does not exist.")

      _ ->
        membership =
          Membership |> where([m], m.challenge_id == ^workout.challenge_id) |> Repo.one()

        if workout.gym_rats_user_id != account_id && (membership == nil || !membership.owner) do
          failure(conn, "You do not have permission to do that.")
        else
          case workout |> Repo.delete() do
            {:ok, workout} -> success(conn, WorkoutView.default(workout))
            {:error, _} -> failure(conn, "Something went wrong.")
          end
        end
    end
  end

  def delete(conn, _params, _account_id), do: failure(conn, "Missing workout id.")
end
