defmodule GymRatsWeb.WorkoutController do
  use GymRatsWeb, :protected_controller

  alias GymRatsWeb.WorkoutView
  alias GymRats.Model.{Workout, Challenge, Membership, WorkoutMedium}
  alias GymRats.{Notification, Repo}

  import Ecto.Query

  def create(conn, params, account_id) do
    {challenges, params} = params |> Map.pop("challenges", [])

    photo_url = List.first(params["media"] || []) |> WorkoutMedium.photo_url()
    params = params |> Map.put("photo_url", params["photo_url"] || photo_url)

    workouts =
      Challenge
      |> join(:left, [c], m in assoc(c, :memberships))
      |> where([_, m], m.gym_rats_user_id == ^account_id)
      |> where([c], c.id in ^challenges)
      |> Repo.all()
      |> Enum.map(fn c ->
        %Workout{challenge_id: c.id, gym_rats_user_id: account_id}
        |> Workout.changeset(params)
        |> Repo.insert()
      end)

    workout = workouts |> List.first()

    if workout == nil do
      failure(conn, "No challenges provided.")
    else
      case workout do
        {:ok, workout} ->
          workout =
            Workout
            |> preload([:account, media: ^from(m in WorkoutMedium, order_by: [asc: m.id])])
            |> Repo.get!(workout.id)

          workouts
          |> Enum.map(fn {:ok, w} -> w end)
          |> Notification.send_workouts()

          success(conn, WorkoutView.with_account_and_media(workout))

        {:error, workout} ->
          failure(conn, workout)
      end
    end
  end

  def show(conn, %{"id" => id}, _account_id) do
    workout =
      Workout
      |> preload([:account, media: ^from(m in WorkoutMedium, order_by: [asc: m.id])])
      |> Repo.get(id)

    case workout do
      nil -> failure(conn, "A workout with id (#{id}) does not exist.")
      _ -> success(conn, WorkoutView.with_account_and_media(workout))
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

  def update(conn, %{"id" => workout_id} = params, account_id) do
    workout_id = String.to_integer(workout_id)

    workout =
      Workout
      |> preload([:account, media: ^from(m in WorkoutMedium, order_by: [asc: m.id])])
      |> Repo.get(workout_id)

    case workout do
      nil ->
        failure(conn, "Workout does not exist.")

      _ ->
        case workout.gym_rats_user_id do
          ^account_id ->
            illegal_params = ~w(id created_at updated_at challenge_id gym_rats_user_id)
            params = params |> Map.drop(illegal_params)
            workout = workout |> Workout.changeset(params) |> Repo.update()

            case workout do
              {:ok, workout} -> success(conn, WorkoutView.with_account_and_media(workout))
              {:error, error} -> failure(conn, error)
            end

          _ ->
            failure(conn, "You do not have permission to do that.")
        end
    end
  end
end
