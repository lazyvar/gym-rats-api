defmodule GymRatsWeb.WorkoutMediumView do
  import GymRatsWeb.JSONView

  @default_attrs ~w(id url thumbnail_url medium_type)a

  def default(media) when is_list(media) do
    media |> Enum.map(fn w -> default(w) end)
  end

  def default(medium) do
    medium |> keep(@default_attrs)
  end
end
