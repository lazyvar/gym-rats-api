defmodule GymRatsWeb.TeamView do
  import GymRatsWeb.JSONView

  @default_attrs ~w(id name photo_url)a

  def default(teams) when is_list(teams) do
    teams
    |> Enum.map(fn c -> default(c) end)
  end

  def default(team) do
    team |> keep(@default_attrs)
  end
end
