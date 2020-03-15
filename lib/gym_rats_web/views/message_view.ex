defmodule GymRatsWeb.MessageView do
  import GymRatsWeb.JSONView

  alias GymRatsWeb.AccountView

  @default_attrs ~w(id content created_at challenge_id)a

  def default(message) do
    message |> keep(@default_attrs)
  end

  def with_account(messages) when is_list(messages) do
    messages |> Enum.map(fn c -> with_account(c) end)
  end

  def with_account(message) do
    message = message |> keep([:account | @default_attrs])

    Map.put(message, :account, AccountView.default(Map.get(message, :account)))
  end
end
