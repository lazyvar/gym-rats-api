defmodule GymRatsWeb.RankingView do
  import GymRatsWeb.JSONView

  alias GymRatsWeb.AccountView

  @default_attrs ~w(account score)a

  def default(rankings) when is_list(rankings) do
    rankings |> Enum.map(fn r -> default(r) end)
  end

  def default(ranking) do
    ranking |> keep(@default_attrs)

    Map.put(ranking, :account, AccountView.default(Map.get(ranking, :account)))
  end
end
