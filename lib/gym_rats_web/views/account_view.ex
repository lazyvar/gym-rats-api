defmodule GymRatsWeb.AccountView do
  alias GymRatsWeb.WorkoutView

  import GymRatsWeb.JSONView
  import Logger

  @default_attrs ~w(id full_name email profile_picture_url)a
  
  def default(account) do
    account 
    |> keep(@default_attrs)
  end

  def with_token(account) do
    account
    |> keep([:token | @default_attrs])
  end

  def with_workouts(accounts) when is_list(accounts) do
    accounts
    |> Enum.map(fn a -> with_workouts(a) end)
  end

  def with_workouts(account) do
    account = account 
    |> keep([:workouts | @default_attrs]) 

    workouts = account 
    |> Map.get(:workouts)
    |> Enum.map(fn w -> WorkoutView.default(w) end)

    Map.put(account, :workouts, workouts)
  end
end
