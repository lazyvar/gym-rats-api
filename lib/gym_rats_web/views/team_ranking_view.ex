defmodule GymRatsWeb.TeamRankingView do
  import GymRatsWeb.JSONView

  alias GymRatsWeb.TeamView

  @default_attrs ~w(team score)a

  def default(rankings) when is_list(rankings) do
    rankings |> Enum.map(fn r -> default(r) end)
  end

  def default(ranking) do
    ranking |> keep(@default_attrs)

    Map.put(ranking, :team, TeamView.with_members(Map.get(ranking, :team)))
  end
end
