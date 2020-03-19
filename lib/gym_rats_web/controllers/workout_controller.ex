defmodule GymRatsWeb.WorkoutController do
  use GymRatsWeb, :protected_controller

  alias GymRatsWeb.WorkoutView
  alias GymRats.Model.{Workout, Challenge, Membership, Account}
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

    workout = workouts |> List.first()
    account = Account |> Repo.get!(account_id)
    workout = Map.put(workout, :account, account)

    success(conn, WorkoutView.with_account(workout))
  end

  def show(conn, %{"id" => id}, account_id) do
    workout = Workout |> preload(:account) |> Repo.get(id)

    case workout do
      nil -> failure(conn, "A workout with id (#{id}) does not exist.")
      _ -> success(conn, WorkoutView.with_account(workout))
    end
  end

  def delete(conn, %{"id" => workout_id}, account_id) do
    workout_id = String.to_integer(workout_id)
    workout = Workout |> Repo.get(workout_id)

    case workout do
      nil ->
        failure(conn, "Workout does not exist.")

      _ ->
        membership =
          Membership
          |> where(
            [m],
            m.challenge_id == ^workout.challenge_id and m.gym_rats_user_id == ^account_id
          )
          |> Repo.one()

        if account_id == workout.gym_rats_user_id || (membership != nil && membership.owner) do
          case workout |> Repo.delete() do
            {:ok, workout} -> success(conn, WorkoutView.default(workout))
            {:error, _} -> failure(conn, "Something went wrong.")
          end
        else
          failure(conn, "You do not have permission to do that.")
        end
    end
  end

  def delete(conn, _params, _account_id), do: failure(conn, "Missing workout id.")
end
