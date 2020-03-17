defmodule GymRatsWeb.Workout.CommentController do
  use GymRatsWeb, :protected_controller

  alias GymRatsWeb.CommentView
  alias GymRats.Model.{Account, Comment}
  alias GymRats.Repo

  import Ecto.Query

  def index(conn, %{"workout_id" => workout_id}, _account_id) do
    comments =
      Comment
      |> where([c], c.workout_id == ^workout_id)
      |> order_by(asc: :created_at)
      |> preload(:account)
      |> Repo.all()

    success(conn, CommentView.with_commenter(comments))
  end

  def create(conn, %{"workout_id" => workout_id} = params, account_id) do
    workout_id = String.to_integer(workout_id)

    comment =
      %Comment{gym_rats_user_id: account_id, workout_id: workout_id}
      |> Comment.changeset(params)
      |> Repo.insert!()

    account = Account |> Repo.get!(account_id)
    comment = Map.put(comment, :account, account)

    success(conn, CommentView.with_commenter(comment))
  end
end
