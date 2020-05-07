defmodule GymRatsWeb.RoomChannel do
  use GymRatsWeb, :channel

  alias GymRatsWeb.{Presence, MessageView}
  alias GymRats.Model.{Account, Message}
  alias GymRats.{Notification, Repo}

  require Logger

  def join("room:challenge:" <> _challenge_id, _params, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_in("new_msg", %{"image_url" => image_url}, socket) do
    account_id = socket.assigns.account_id

    challenge_id =
      socket.topic |> String.split(":", trim: true) |> List.last() |> String.to_integer()

    message = %Message{
      content: image_url,
      gym_rats_user_id: account_id,
      challenge_id: challenge_id,
      message_type: "image"
    }

    message = Message.changeset(message, %{}) |> Repo.insert!()
    account = Account |> Repo.get!(account_id)
    message = Map.put(message, :account, account)

    Notification.send_chat_message(message)

    broadcast!(socket, "new_msg", MessageView.with_account(message))

    {:noreply, socket}
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

    Notification.send_chat_message(message)

    broadcast!(socket, "new_msg", MessageView.with_account(message))

    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", Presence.list(socket))

    {:ok, _} =
      Presence.track(socket, "account:#{socket.assigns.account_id}", %{
        online_at: System.system_time(:second)
      })

    {:noreply, socket}
  end

  def handle_info(_thing, socket), do: {:noreply, socket}
end
