defmodule GymRatsWeb.ChallengeView do
  import GymRatsWeb.JSONView

  @default_attrs ~w(id name code profile_picture_url start_date end_date)a

  def default(challenges) when is_list(challenges) do
    challenges
    |> Enum.map(fn c -> default(c) end)
  end

  def default(challenge) do
    challenge |> keep(@default_attrs)
  end
end
