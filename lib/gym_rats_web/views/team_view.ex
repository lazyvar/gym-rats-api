defmodule GymRatsWeb.TeamView do
  import GymRatsWeb.JSONView

  alias GymRatsWeb.AccountView

  @default_attrs ~w(id name photo_url)a

  def default(teams) when is_list(teams) do
    teams
    |> Enum.map(fn t -> default(t) end)
  end

  def default(team) do
    team |> keep(@default_attrs)
  end

  def with_members(teams) when is_list(teams) do
    teams
    |> Enum.map(fn t -> with_members(t) end)
  end

  def with_members(team) do
    team = team |> keep([:members | @default_attrs])

    Map.put(team, :members, AccountView.default(Map.get(team, :members)))
  end
end
