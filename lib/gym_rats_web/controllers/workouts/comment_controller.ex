defmodule GymRatsWeb.Workout.CommentController do
  use GymRatsWeb, :protected_controller
  
  alias GymRatsWeb.CommentView
  alias GymRats.Model.Comment
  alias GymRats.Repo
  
  import Ecto.Query
  
  def index(conn, %{"workout_id" => workout_id}, _account_id) do
    comments = Comment
    |> where([c], c.workout_id == ^workout_id)
    |> order_by(asc: :inserted_at)
    |> preload(:account)
    |> Repo.all

    success(conn, CommentView.with_commenter(comments))
  end

  def create(conn, %{"workout_id" => workout_id} = params, account_id) do
    workout_id = String.to_integer(workout_id)
    comment = %Comment{gym_rats_user_id: account_id, workout_id: workout_id}
    |> Comment.changeset(params)
    |> Repo.insert

    case comment do
      {:ok, comment} -> success(conn, CommentView.default(comment))
      {:error, comment} -> failure(conn, comment)
    end
  end
end