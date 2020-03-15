defmodule GymRatsWeb.Challenge.MessageController do
  use GymRatsWeb, :protected_controller

  alias GymRatsWeb.MessageView
  alias GymRats.Model.Message
  alias GymRats.Repo

  import Ecto.Query

  def index(conn, %{"challenge_id" => challenge_id, "page" => page}, _account_id) do
    challenge_id = String.to_integer(challenge_id)
    page = String.to_integer(page)

    messages =
      Message
      |> join(:left, [m], c in assoc(m, :challenge))
      |> where([m, c], m.challenge_id == ^challenge_id)
      |> offset(40 * ^page)
      |> limit(40)
      |> order_by(desc: :created_at)
      |> preload(:account)
      |> Repo.all()

    success(conn, MessageView.with_account(messages))
  end

  def index(conn, _params, _account_id), do: failure(conn, "Missing challenge id.")
end

# unread_chats = UserReadMessage.where(gym_rats_user_id: @user.id, challenge_id: challenge.id, read: false)
# unread_chats.each do |chat|
#     chat.read = true
#     chat.save
# end
