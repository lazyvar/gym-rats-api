defmodule GymRatsWeb.AccountView do
  alias GymRatsWeb.WorkoutView

  import GymRatsWeb.JSONView

  @default_attrs ~w(id full_name email profile_picture_url)a
  @current_user_attrs ~w(token workout_notifications_enabled comment_notifications_enabled chat_message_notifications_enabled)a

  def default(accounts) when is_list(accounts) do
    accounts |> Enum.map(fn a -> default(a) end)
  end

  def default(account) do
    account |> keep(@default_attrs)
  end

  def for_current_user(account) do
    account |> keep(@default_attrs ++ @current_user_attrs)
  end

  def with_workouts(accounts) when is_list(accounts) do
    accounts |> Enum.map(fn a -> with_workouts(a) end)
  end

  def with_workouts(account) do
    account = account |> keep([:workouts | @default_attrs])

    workouts =
      account
      |> Map.get(:workouts)
      |> Enum.map(fn w -> WorkoutView.default(w) end)

    Map.put(account, :workouts, workouts)
  end
end
