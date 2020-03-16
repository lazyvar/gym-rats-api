defmodule GymRatsWeb.RoomChannel do
  use GymRatsWeb, :channel

  alias GymRatsWeb.MessageView
  alias GymRats.Model.{Account, Message}
  alias GymRats.Repo

  import Ecto.Query

  def join("room:challenge:" <> _challenge_id, _params, socket) do
    {:ok, socket}
  end

  def handle_in("new_msg", %{"message" => message}, socket) do
    account_id = socket.assigns.account_id

    challenge_id =
      socket.topic |> String.split(":", trim: true) |> List.last() |> String.to_integer()

    message = %Message{
      content: message,
      gym_rats_user_id: account_id,
      challenge_id: challenge_id
    }

    message = Message.changeset(message, %{}) |> Repo.insert!()
    account = Account |> Repo.get!(account_id)
    message = Map.put(message, :account, account)

    broadcast!(socket, "new_msg", MessageView.with_account(message))

    {:noreply, socket}
  end
end
