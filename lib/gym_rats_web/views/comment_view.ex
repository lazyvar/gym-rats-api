defmodule GymRatsWeb.CommentView do
  import GymRatsWeb.JSONView

  alias GymRatsWeb.AccountView

  @default_attrs ~w(id content created_at workout_id)a

  def default(comment) do
    comment |> keep(@default_attrs)
  end

  def with_commenter(comments) when is_list(comments) do
    comments
    |> Enum.map(fn c -> with_commenter(c) end)
  end

  def with_commenter(comment) do
    comment =
      comment
      |> keep([:account | @default_attrs])

    Map.put(comment, :account, AccountView.default(Map.get(comment, :account)))
  end
end
