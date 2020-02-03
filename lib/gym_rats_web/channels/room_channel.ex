defmodule GymRatsWeb.RoomChannel do
  use GymRatsWeb, :channel

  def join(_, _params, socket) do
    {:ok, socket}
  end

  def handle_in("new_msg", %{"message" => body}, socket) do
    broadcast!(socket, "new_msg", %{message: socket.assigns.name <> ": " <> body})
    {:noreply, socket}
  end
end
