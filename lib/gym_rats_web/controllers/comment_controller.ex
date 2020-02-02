defmodule GymRatsWeb.CommentController do
  use GymRatsWeb, :protected_controller
  
  alias GymRatsWeb.CommentView
  alias GymRats.Model.Comment

  import Ecto.Query

  def delete(conn, %{"id" => id}, account_id) do
    comment = Comment |> Repo.get(id)

    case comment do
      nil -> failure(conn, "Comment does not exist")
      _ ->
        if comment.gym_rats_user_id != account_id do
          failure(conn, "You do not have permission to do that.")
        else
          comment |> Repo.delete!
          success(conn, CommentView.default(comment))
        end
      end
  end
end