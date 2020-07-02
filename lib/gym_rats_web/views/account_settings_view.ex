defmodule GymRatsWeb.AccountSettingsView do
  import GymRatsWeb.JSONView

  @default_attrs ~w(workout_notifications_enabled comment_notifications_enabled chat_message_notifications_enabled)a

  def default(account) do
    account |> keep(@default_attrs)
  end
end